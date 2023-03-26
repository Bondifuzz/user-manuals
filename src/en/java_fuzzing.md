
# Java

**Java is not supported, but we are working on it.**

`Jazzer` -- is a Java-based fuzzer that works using `libfuzzer`.

## Installation

[Jazzer](https://github.com/CodeIntelligenceTesting/jazzer) is built using `bazel`. Before building it, you have to specify the required version `jazzer/.bazelversion`. 

If you can't find a certain version in the package list of the distributive, you can download it from [github](https://github.com/bazelbuild/bazel) or [releases.bazel.build](https://releases.bazel.build).

Let's say you need version `5.2.0rc1`, and you can find it [here](https://releases.bazel.build/5.2.0/rc1/index.html).

Installation process:

`git clone https://github.com/CodeIntelligenceTesting/jazzer`  
`cd jazzer`  
`bazel build //:jazzer_release`  
`cd bazel-bin`  
`tar -xzf jazzer_release.tar.gz`  

The result is a binary called `./jazzer` and its dependencies. Here's a detail: you have to explicitly call `jazzer` by specifying the path. You can't move `jazzer` and its dependencies to `/usr/local/bin` and use search in `PATH`:

`jazzer`
`Could not find jazzer_agent_deploy.jar. Please provide the pathname via the --agent_path flag`  

The dependencies will be lost because the search is based on the provided path to `jazzer`:

`./jazzer`  
`bazel-bin/jazzer`  
`jazzer/bazel-bin/jazzer`  
etc.

You can create a variable `JAZZER=/path/jazzer/bazel-bin/jazzer` and use it.

## Execution examples

`Jazzer` is executed this way:

`$JAZZER --cp=fuzz_target.jar:lib1.jar:lib2.jar --target_class=com.example.MyFirstFuzzTarget <options>`

Where:

* `--cp=fuzz_target.jar:lib1.jar:lib2.jar` -- points to a tested module and its dependencies
* `--target_class=com.example.MyFirstFuzzTarget` -- tested class in the module
* `<options>` - [options](https://llvm.org/docs/LibFuzzer.html#options) `libfuzzer`

## Tested class

As a target, you can have a class with one of the following methods:

1. `public static void fuzzerTestOneInput(byte[] input)`
2. `public static void fuzzerTestOneInput(FuzzedDataProvider data)`

### Example 1: DivZero

This example is about `fuzzerTestOneInput(byte[] input)`.

Project structure:

```
src/main/java/com/example/
    DivZero.java
BUILD.bazel
WORKSPACE
```

`WORKSPACE` is empty here, but it has to be filled in.

`DivZero.java`:

```java
package com.example;

public class DivZero{

    public static void fuzzerTestOneInput(byte[] input){

        if(input.length > 1){
            double a = input[0] / (input[1]-2);
        }

    }
}
```

`BUILD.bazel`:
```
java_binary(
    name = "DivZero",
    srcs = ["src/main/java/com/example/DivZero.java"]
)
```

Build:

`bazel build //:DivZero`

The result is an archive called `bazel-bin/DivZero.jar`.

Start the fuzzing process:

`$JAZZER --cp=bazel-bin/DivZero.jar --target_class=com.example.DivZero`

### Example 2: log4j

This example considers `fuzzerTestOneInput(FuzzedDataProvider data)`.

`data` is an object with `com.code_intelligence.jazzer.api.FuzzedDataProvider` interface. Its function is to pre-process byte arrays. In this example, an array is transformed into a valid string.

Project structure:

```
src/main/java/com/
    code_intelligence/jazzer/api/
        FuzzedDataProvider.java
    example/
        Log4jFuzzer.java

corpus/
    123

maven.bzl
BUILD.bazel
WORKSPACE
```

You can find the sources for classes here: [Log4jFuzzer.java](https://github.com/CodeIntelligenceTesting/jazzer/blob/main/examples/src/main/java/com/example/Log4jFuzzer.java), [FuzzedDataProvider.java](https://github.com/CodeIntelligenceTesting/jazzer/blob/main/agent/src/main/java/com/code_intelligence/jazzer/api/FuzzedDataProvider.java).

### maven.bzl

`maven.bzl` is meant for downloading dependencies. In the `log4j` example, those are modules:

1. log4j-api
2. log4j-core

That's what `maven.bzl` looks like:

```
load("@rules_jvm_external//:specs.bzl", "maven")

MAVEN_ARTIFACTS = [
    maven.artifact("org.apache.logging.log4j", "log4j-api", "2.14.1", testonly = True),
    maven.artifact("org.apache.logging.log4j", "log4j-core", "2.14.1", testonly = True),
]
```

`maven` should be introduced to a build through `WORKSPACE`.

### WORKSPACE

That's what it looks like:

```
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file", "http_jar")

http_archive(
    name = "rules_jvm_external",
    sha256 = "f36441aa876c4f6427bfb2d1f2d723b48e9d930b62662bf723ddfb8fc80f0140",
    strip_prefix = "rules_jvm_external-4.1",
    url = "https://github.com/bazelbuild/rules_jvm_external/archive/refs/tags/4.1.zip",
)

load("@rules_jvm_external//:defs.bzl", "maven_install")
load("//:maven.bzl", "MAVEN_ARTIFACTS")

maven_install(
    artifacts = MAVEN_ARTIFACTS,
    fail_if_repin_required = False,
    repositories = [
        "https://repo1.maven.org/maven2",
    ],
    strict_visibility = True,
)

load("@maven//:defs.bzl", "pinned_maven_install")

pinned_maven_install()
```

But that's not all. You have to generate `maven_install.json` with all the information about dependencies:

`bazel run @maven//:pin`

Then add this file to `maven_install` in `WORKSPACE`:

```
maven_install(
    artifacts = MAVEN_ARTIFACTS,
    fail_if_repin_required = False,
    maven_install_json = "//:maven_install.json",
    repositories = [
        "https://repo1.maven.org/maven2",
    ],
    strict_visibility = True,
)
```

Now you can build it.

### Build

```
bazel build //:Log4jFuzzer
```

The fuzzing test suite will be located in `bazel-bin/Log4jFuzzer.jar`, and its dependencies by the following paths:

1. `bazel-bin/external/maven/v1/https/repo1.maven.org/maven2/org/apache/logging/log4j/log4j-core/2.14.1/log4j-core-2.14.1.jar`
2. `bazel-bin/external/maven/v1/https/repo1.maven.org/maven2/org/apache/logging/log4j/log4j-api/2.14.1/log4j-api-2.14.1.jar`

## Running the fuzzing test suite

Here's how to run it:

```
LOG4J=bazel-bin/external/maven/v1/https/repo1.maven.org/maven2/org/apache/logging/log4j
LOG4J_CORE=$LOG4J/log4j-core/2.14.1/log4j-core-2.14.1.jar
LOG4J_API=$LOG4J/log4j-api/2.14.1/log4j-api-2.14.1.jar

FUZZER=bazel-bin/Log4jFuzzer.jar

$JAZZER --cp=$FUZZER:$LOG4J_CORE:$LOG4J_API --target_class=com.example.Log4jFuzzer ./corpus

```

In the `corpus` directory, there's a file called `123` with

`cat 123`  
`ldap://g.co/`  

Its content can be anything, and there may by any number of such files.