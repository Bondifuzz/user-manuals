
# Python

## Установка atheris

`atheris` — фаззер для кода на языке Python, работает на основе `libfuzzer`. Устанавливается командой:

```bash
pip3 install atheris
```

Второй вариант установки — сброка из репозитория [atheris](https://github.com/google/atheris)

```bash
pip3 install --no-binary atheris atheris
git clone https://github.com/google/atheris.git
cd atheris
pip3 install .
```

## Инструментация

Инструментировать можно разными способами.

С помощью функций:

```python
@atheris.instrument_func
def my_function(foo, bar):
  print("instrumented")
```

С помощью модулей:

```python
with atheris.instrument_imports():
  import foo
  from bar import baz
```

Одновременно с помощью функций и модулей:

```python
atheris.instrument_all()
atheris.Setup()
```

### Пример 1: Hello, Fuzzer! (тестируем на наличие ошибки типа DivZero)

Есть функция, в которой иногда происходит деление на ноль:

```python
def TestOneInput(data):
    
    if len(data) < 2:
        return 0

    a = data[0]
    b = data[1]

    c = a / (b - 30)

```

Фаззинг-тест для этой функции будет выглядеть так:

```python
import atheris
import sys

@atheris.instrument_func
def TestOneInput(data):
    
    if len(data) < 2:
        return 0

    a = data[0]
    b = data[1]

    c = a / (b - 30)


atheris.Setup(sys.argv, TestOneInput)
atheris.Fuzz()

```

### Пример 2: Ищем уязвимости в Pillow ([CVE-2021-34552](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2021-34552))

CVE-2021-34552 — это пример небезопасного использования функции `sprintf` в модуле на языке C [_imaging](https://github.com/python-pillow/Pillow/pull/5567/files). Приводит к stackoverflow.

Сборка Pillow выполняется следующей командой:

```bash
git clone https://github.com/python-pillow/Pillow
cd Pillow
git checkout 8.2.0 && python3 ./setup.py build
```

Фаззинг-тест выглядит таким образом:

```python
import atheris
import importlib.util
import sys

def import_PIL(src):
    spec = importlib.util.spec_from_file_location("PIL", "{}/__init__.py".format(src))
    PIL_ = importlib.util.module_from_spec(spec)
    sys.modules["PIL"] = PIL_

    spec.loader.exec_module(PIL_)

    globals().update({"PIL": PIL_})

    
src = 'path/to/Pillow/build/lib.linux-x86_64-3.8/PIL'
import_PIL(src)

from PIL import Image

@atheris.instrument_func
def TestOneInput(data):

    data = data.decode()

    try:
        with Image.open("some.jpg") as img:
            img.convert(mode=data)
    except ValueError:
        pass

atheris.Setup(sys.argv, TestOneInput)
atheris.Fuzz()
```

Модуль `PIL` импортируется не из системной директории, а из кастомной, чтобы не засорять систему.

Для запуска понадобится любая картинка формата `.jpg`.

Блок `try except` необходим потому, что модуль будет сыпать исключениями, что сразу остановит фаззинг.

#### Запуск

```bash
./pillow-fuzzer.py ./corpus -only_ascii=1
```

Опции идентичны опциям [`libfuzzer`](https://llvm.org/docs/LibFuzzer.html).

Здесь `corpus` — это корпус стартовых тест-кейсов. В этом примере можно использовать простой вариант:

```bash
echo 123 > corpus/123
```

`-only_ascii=1` — требование генерировать тест-кейсы, в которых есть только ASCII символы, как того требует исследуемая функция `_imaging.convert` 

