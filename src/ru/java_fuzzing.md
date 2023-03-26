
# Java (JVM-based)

(Поддержка Java находится в разработке.)

`Jazzer` -- это фаззер для кода на языке программирования Java, работает через `libfuzzer`.

## Установка

[Jazzer](https://github.com/CodeIntelligenceTesting/jazzer) собирается при помощи `bazel`. Прежде чем собирать, необходимо уточнить требуемую версию `jazzer/.bazelversion`. 

Если такой версии нет в списке пакетов дистрибутива, то необходимо скачать ее либо с [github](https://github.com/bazelbuild/bazel), либо с [releases.bazel.build](https://releases.bazel.build).

Например, необходима версия `5.2.0rc1`, берем [отсюда](https://releases.bazel.build/5.2.0/rc1/index.html).

Сам процесс установки выглядит так:

```bash
git clone https://github.com/CodeIntelligenceTesting/jazzer
cd jazzer
bazel build //:jazzer_release
cd bazel-bin
tar -xzf jazzer_release.tar.gz
```

Результат сборки -- бинарный файл `./jazzer` и его зависимости. Тут кроется одна особенность -- необходимо явно вызывать `jazzer`, указывая путь. Не получится добавить `jazzer` и его зависимости в `/usr/local/bin` и воспользоваться поиском в `PATH`:

```bash
jazzer  
Could not find jazzer_agent_deploy.jar. Please provide the pathname via the --agent_path flag.
```

Зависимости потеряются, потому что поиск опирается на указанный путь до `jazzer`:

```bash
./jazzer
bazel-bin/jazzer
jazzer/bazel-bin/jazzer
```

и т.д.

Можно создать переменную `JAZZER=/path/jazzer/bazel-bin/jazzer` и пользоваться ей.

## Параметры запуска

`Jazzer` имеет следующий формат запуска:

```bash
$JAZZER --cp=fuzz_target.jar:lib1.jar:lib2.jar --target_class=com.example.MyFirstFuzzTarget <options>
```

Где:

* `--cp=fuzz_target.jar:lib1.jar:lib2.jar` указывает на исследуемый модуль и его зависимости  
* `--target_class=com.example.MyFirstFuzzTarget` - на исследуемый класс в модуле  
* `<options>` - [опции](https://llvm.org/docs/LibFuzzer.html#options) `libfuzzer`  

## Исследуемый класс

В качестве цели может выступать класс с одним из методов:

1. `public static void fuzzerTestOneInput(byte[] input)`
2. `public static void fuzzerTestOneInput(FuzzedDataProvider data)`

### Пример 1: Hello, Fuzzer! (тестируем на наличие ошибки типа DivZero)

Это пример про `fuzzerTestOneInput(byte[] input)`.

Структура проекта:

```bash
src/main/java/com/example/
    DivZero.java
BUILD.bazel
WORKSPACE
```

`WORKSPACE` - в данном примере пуст, но он должен быть.

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

Сборка:

```bash
bazel build //:DivZero
```

Результат - архив `bazel-bin/DivZero.jar`.

Запуск фаззинга:

```bash
$JAZZER --cp=bazel-bin/DivZero.jar --target_class=com.example.DivZero
```

### Пример 2: Ищем CVE-2021-44228 в log4j

Это пример про `fuzzerTestOneInput(FuzzedDataProvider data)`.

`data` - это объект с интерфейсом `com.code_intelligence.jazzer.api.FuzzedDataProvider`, он необходим для предобработки очередного массива байт. В этом примере массив будет преобразовываться в валидную строку.

Структура проекта:

```bash
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

Исходные коды для классов можно найти здесь: [Log4jFuzzer.java](https://github.com/CodeIntelligenceTesting/jazzer/blob/main/examples/src/main/java/com/example/Log4jFuzzer.java), [FuzzedDataProvider.java](https://github.com/CodeIntelligenceTesting/jazzer/blob/main/agent/src/main/java/com/code_intelligence/jazzer/api/FuzzedDataProvider.java).

#### maven.bzl

`maven.bzl` необходим для того, чтобы скачать зависимости, в примере с `log4j` это модули:

1. log4j-api
2. log4j-core

Выглядит `maven.bzl` так:

```
load("@rules_jvm_external//:specs.bzl", "maven")

MAVEN_ARTIFACTS = [
    maven.artifact("org.apache.logging.log4j", "log4j-api", "2.14.1", testonly = True),
    maven.artifact("org.apache.logging.log4j", "log4j-core", "2.14.1", testonly = True),
]
```

Сам `maven` надо встроить в сборку через `WORKSPACE`.

#### WORKSPACE

Выглядит так:

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

Но это еще не все, теперь необходимо сгенерировать файл `maven_install.json`, который будет содержать всю информацию о зависимостях:

```bash
bazel run @maven//:pin
```

Далее этот файл необходимо добавить в `WORKSPACE` в `maven_install`:

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

Теперь можно приступить к сборке.

#### Сборка

```bash
bazel build //:Log4jFuzzer
```

Фаззинг-тест будет находиться в `bazel-bin/Log4jFuzzer.jar`, а его зависимости по следующим адресам:

1. `bazel-bin/external/maven/v1/https/repo1.maven.org/maven2/org/apache/logging/log4j/log4j-core/2.14.1/log4j-core-2.14.1.jar`
2. `bazel-bin/external/maven/v1/https/repo1.maven.org/maven2/org/apache/logging/log4j/log4j-api/2.14.1/log4j-api-2.14.1.jar`

#### Запуск

Запуск фаззинг-теста осуществляется следующими командами:

```
LOG4J=bazel-bin/external/maven/v1/https/repo1.maven.org/maven2/org/apache/logging/log4j
LOG4J_CORE=$LOG4J/log4j-core/2.14.1/log4j-core-2.14.1.jar
LOG4J_API=$LOG4J/log4j-api/2.14.1/log4j-api-2.14.1.jar
...
FUZZER=bazel-bin/Log4jFuzzer.jar
...
$JAZZER --cp=$FUZZER:$LOG4J_CORE:$LOG4J_API --target_class=com.example.Log4jFuzzer ./corpus
```

В директории `corpus` находится файл `123` с содержимым

```bash
cat 123
ldap://g.co/
```

Содержимое может быть любым и файлов может быть сколько угодно.
