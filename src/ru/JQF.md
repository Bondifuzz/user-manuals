
# JQF

(Поддержка языка программирования Java находится в разработке.)

JQF — это платформа для фаззинга языка Java с обратной связью (например, AFL/LibFuzzer, но для байт-кода JVM).

Есть два способа работы с `JQF`:

* через плагин `maven`
* через программу `jqf-zest`

У первого способа больше опций, но он требует код проекта. У второго способа меньше опций, но ему достаточно скомпилированных файлов.

Чтобы объединить плюсы обоих способов, `jqf` был пропатчен, и появился третий - в `jqf-zest`. В нем больше больше полезных опций.

Расскажем обо всех вариантах подробнее.

## Maven

У этого способа больше опций, но он требует код проекта.

### Создание шаблона проекта

Шаблон проекта создается следующим способом:

```bash
mvn archetype:generate -DgroupId=com.example.fuzzer -DartifactId=your-project-name -DarchetypeArtifactId=maven-archetype-quickstart -DarchetypeVersion=1.4 -DinteractiveMode=false
```

После создания появится директория `your-project-name`:

```bash
your-project-name/
    src/
       main/java/com/example/fuzzer/App.java 
       test/java/com/example/fuzzer/App.java
    pom.xml
```

Параметры сборки хранятся в `pom.xml`, код фаззинг-теста — в `test/java/com/example/fuzzer/`.

`App.java` можно удалить ввиду ненадобности.

В `pom.xml` необходимо добавить зависимости `jqf`:

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

Потом обязательно проверить `<maven.compiler.source|target>`, по умолчанию там будет `1.7`, надо проставить свою версию `jvm`. Например, `11`.

Код фаззинг-тест имеет вид:

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

### Сборка

Сборка осуществляется следующей командой:

```bash
mvn install
```

### Запуск

Запуск осуществляется командой:

```bash
mvn jqf:fuzz -Dclass=com.example.fuzzer.Fuzz -Dmethod=fuzz
```

Опции запуска ([src](https://github.com/rohanpadhye/JQF/blob/master/maven-plugin/src/main/java/edu/berkeley/cs/jqf/plugin/FuzzGoal.java)) могут быть следующимиы:

* `-Dclass` — исследуемый класс
* `-Dmethod` — метод, в который подавать входные данные
* `-Dexcludes` — какие классы не нужно инструментировать
* `-Dincludes` — какие классы необходимо инструментировать
* `-Dtime` — через сколько остановить фаззинг
* `-Dtrials` — через сколько итераций остановить фаззинг
* `-DrandomSeed` — число, которое определит порядок мутаторов
* `-Dblind` — не учитывать покрытие, брутфорс
* `-Dengine` — может быть `zest` или `zeal`
* `-DnoCov` — отключить инструментацию, брутфорс
* `-Din` — корпус
* `-Dout` — выхлоп
* `-DsaveAll` — сохранять тест-кейсы, которые не дают уникальное покрытие
* `-DlibFuzzerCompatOutput` — вывод статистики в формате LibFuzzer-а
* `-DexitOnCrash` — остановить фаззинг при первом крэше
* `-DrunTimeout` — таймаут
* `-DfixedSize` — постоянный размер тест-кейса

### Пример 1: Hello, Fuzzer! (тестируем на наличие ошибки типа DivZero)

Код фаззинг-теста:

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

У этого способа меньше опций, но для работы достаточно скомпилированных файлов.

### Запуск

Запускается следующей командой:

```bash
/path/to/jqf/bin/jqf-zest -c .:$(/path/to/jqf/scripts/classpath.sh) TEST_CLASS TEST_METHOD OUTPUT_DIR SEED_DIR
```

Здесь 4 опции для `jqf-zest`, которые говорят сами за себя, и 1 опция для `jvm`.

Через `-c` указываются пути, где искать `.jar` архивы. Скрипт `classpath.sh` находит только архивы `jqf`. А добавлять свои необходимо так:

```bash
-c mypackage1.jar:mypackage2.jar:$(/path/to/jqf/scripts/classpath.sh)
```

### Пропатченный jqf-zest

Патчем добавлены следующие опции:

* `bondi.time_limit` - число в мс (по умолчанию 0)
* `bondi.output` - куда сохранять (`fuzz-results`)
* `bondi.input`  - откуда брать (`fuzz-input`)
* `bondi.crash_log_path` - (`./crash_log.txt`)
* `bondi.crash_data_path` - (`./crash_data`)
* `bondi.max_len` - (10240)
* `bondi.child_timeout` - (null)
* `bondi.seed` - (пусто)


Устанавливаются таким образом:

```bash
JAVA_TOOL_OPTIONS="-Dbondi.time_limit=360000 -Dbondi.execs=10000000 -Dbondi.output=out -Dbondi.input=corpus /path/to/jqf/bin/jqf-zest -c .:$(/path/to/jqf/scripts/classpath.sh) TEST_CLASS TEST_METHOD
```

## Zest

Zest - это алгоритм, который превращает обычный фаззинг в структурный.

Подробности в [статье](https://rohan.padhye.org/files/zest-issta19.pdf).

Обычный фаззинг - тот, который работает с "сырым" массивом байт. Структурный - с пользовательскими типами данных, умеет создавать любые объекты.

Обычный фаззинг не в состоянии сгенерировать валидный, например, документ `xml`. А все невалидное будет отброшено исследуемым кодом, никакого результата не будет, кроме потраченного времени.

Валидные объекты можно создавать, например, через библиотеку `junit-quickcheck`.

Пользователь создает генератор, который производит такие объекты на основе рандома.

Пример логики генератора xml:

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

Результат:

```
<foo><bar>Hello</bar><baz /></foo>
```

То есть это целиком работа пользователя, как он справится с генератором, так он и будет работать. Фаззер просто будет забирать готовые объекты.

Но оно опирается на рандом и для фаззинга пока еще не годится, потому что нет учета покрытия.

Учет покрытия реализован через алгоритм `Zest`. 

Как указывается в статье, `Zest` вмешивается в работу `Random`, берет под контроль поток битов в нем. 

Один и тот же поток приводит к созданию одних и тех же объектов. То есть `Zest` нет необходимости что-то знать об объектах, чтобы оценить их влияение на покрытие. Когда приходит время мутировать данные, `Zest` мутирует биты в потоке.

Таким образом, авторы `Zest` свели структурный фаззинг к обычному, работают с массивом байт, просто издалека.
