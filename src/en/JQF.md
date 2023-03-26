
# JQF

**Java is not supported, but we are working on it.**

JQF is a fuzzing platform for Java with feedback (e.g., AFL/LibFuzzer but for JVM byte code).

There are two ways of working with `JQF`:

* using the `maven` plugin
* using `jqf-zest`.

`maven` offers more options, but it requires the project's code. `jqf-zest` is less versatile, but it only needs compiled files.

To combine the advantages of both ways, `JQF` was patched, so now we have `jqf-zest`, which offers more useful options.

Let's take a closer look at each one of them.

## Maven

Maven has more options, but it requires the project's code.

### Creating a project template

Here's how to create a project template:

`mvn archetype:generate -DgroupId=com.example.fuzzer -DartifactId=your-project-name -DarchetypeArtifactId=maven-archetype-quickstart -DarchetypeVersion=1.4 -DinteractiveMode=false`

Once the template is created, you'll see a directory named `your-project-name`:

```
your-project-name/
    src/
       main/java/com/example/fuzzer/App.java 
       test/java/com/example/fuzzer/App.java
    pom.xml
```

Build parameters are stored in `pom.xml`, fuzzing test suite's code in `test/java/com/example/fuzzer/`.

`App.java` can be deleted.

In `pom.xml`, add `jqf` dependencies:

```xml
<dependency>
    <groupId>edu.berkeley.cs.jqf</groupId>
    <artifactId>jqf-fuzz</artifactId>
    <version>1.9</version>
</dependency>

<plugin>
    <groupId>edu.berkeley.cs.jqf</groupId>
    <artifactId>jqf-maven-plugin</artifactId>
    <version>1.9</version>
</plugin>
```

Then, check `<maven.compiler.source|target>`: it's `1.7` by default, so make sure to write your `jvm` version (e.g., `11`).

Here's the fuzzing test suite's code:

```java
// test/java/com/example/fuzzer/Fuzz.java

package com.example.fuzzer;

import edu.berkeley.cs.jqf.fuzz.Fuzz;
import edu.berkeley.cs.jqf.fuzz.JQF;
import org.junit.runner.RunWith;

@RunWith(JQF.class)
public class Fuzz{

    @Fuzz
    public void fuzz(byte[] data) {
        ...
    }

}
```

### Build

Build using this command:

`your-project-name$ mvn install`

### Execution

Run `JQF` using this command:

`your-project-name$ mvn jqf:fuzz -Dclass=com.example.fuzzer.Fuzz -Dmethod=fuzz`

Execution options ([src](https://github.com/rohanpadhye/JQF/blob/master/maven-plugin/src/main/java/edu/berkeley/cs/jqf/plugin/FuzzGoal.java)) are:

* `-Dclass` - tested class
* `-Dmethod` - input is fed to this method
* `-Dexcludes` - classes to exclude from instrumentation
* `-Dincludes` - classes to include into instrumentation
* `-Dtime` - when to stop fuzzing
* `-Dtrials` - after how many iterations to stop fuzzing
* `-DrandomSeed` - the seed to determine the order of mutators
* `-Dblind` - disregard coverage, brute force
* `-Dengine` - `zest` or `zeal`
* `-DnoCov` - disable instrumentation, brute force
* `-Din` - corpus
* `-Dout` - output
* `-DsaveAll` - save test cases that do not provide unique coverage
* `-DlibFuzzerCompatOutput` - output stats in the LibFuzzer format
* `-DexitOnCrash` - stop fuzzing on first crash
* `-DrunTimeout` - timeout
* `-DfixedSize` - fixed test case size

### DivZero example

Fuzzing test suite's code:

```java
package com.example.fuzzer;

import edu.berkeley.cs.jqf.fuzz.Fuzz;
import edu.berkeley.cs.jqf.fuzz.JQF;
import org.junit.runner.RunWith;

@RunWith(JQF.class)
public class DivZero{

    @Fuzz
    public void fuzz(byte[] data) {
        if(data.length > 1){
            double a = data[0] / (data[1]-2);
        }
    }

}
```

## jqf-zest

`jqf-zest` has less options but it only needs compiled files to work.

### Execution

To run `jqf-zest`, use this command:

`/path/to/jqf/bin/jqf-zest -c .:$(/path/to/jqf/scripts/classpath.sh) TEST_CLASS TEST_METHOD OUTPUT_DIR SEED_DIR`

There are four self-explanatory `jqf-zest` options and one for `jvm`.

Use `-c` to provide paths to `.jar` archives. The `classpath.sh` script can only find `jqf` archives.

Here's how to add your own:

`-c mypackage1.jar:mypackage2.jar:$(/path/to/jqf/scripts/classpath.sh)`

### Patched jqf-zest

The patch adds the following options:

* `bondi.time_limit` - time in ms (0 by default)
* `bondi.output` - where to save output (`fuzz-results`)
* `bondi.input`  - where to get input from (`fuzz-input`)
* `bondi.crash_log_path` - (`./crash_log.txt`)
* `bondi.crash_data_path` - (`./crash_data`)
* `bondi.max_len` - (10240)
* `bondi.child_timeout` - (null)
* `bondi.seed` - (empty)

Installation:

```
JAVA_TOOL_OPTIONS=" \
        -Dbondi.time_limit=360000 \
        -Dbondi.execs=10000000 \
        -Dbondi.output=out \
        -Dbondi.input=corpus \
" \
/path/to/jqf/bin/jqf-zest -c .:$(/path/to/jqf/scripts/classpath.sh) TEST_CLASS TEST_METHOD
```

## Zest

Zest is an algorithm that turns regular fuzzing into structured fuzzing.

You can find more about it [here](https://rohan.padhye.org/files/zest-issta19.pdf).

Regular fuzzing works with an array of bytes. Structured fuzzing works with custom data types and can create any objects.

For example, regular fuzzing cannot generate a valid `xml` document. The tested code will reject invalid data, and fuzzing won't deliver any results.

Valid objects can be created using the `junit-quickcheck` library.

A user creates a generator that randomly generates such objects.

Example of an `xml` generator:

```
random.nextInt(1, MAX_STRLEN) → 3 
random.nextChar() → ‘f’ 
random.nextChar() → ‘o’ 
random.nextChar() → ‘o’ 
random.nextInt(MAX_CHILDREN) → 2 
random.nextInt(1, MAX_STRLEN) → 3
...
random.nextBool() → False 
random.nextBool() → False 
```

Results:

`<foo><bar>Hello</bar><baz /></foo>`

So, this is totally up to the user: the results depend on how they handle the generator. The fuzzing test suite only gets generated objects.

As for now, the process is based on random values is not suitable for fuzzing, as it does not account for coverage.

Coverage is assessed by the `Zest` algorithm. 

As stated in the source article, `Zest` intervenes in `Random`'s workflow and takes over control of the bit stream in it. 

Only similar objects can be generated from the same stream. Thus, `Zest` doesn't need to know anything about the objects to assess their contribution towards coverage. When the time to mutate data comes, `Zest` mutates bites in the stream.

Thus, the authors of `Zest` reduced structured fuzzing back to regular – they work with arrays of bytes but from afar.