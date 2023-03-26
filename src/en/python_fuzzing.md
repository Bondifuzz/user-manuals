
# Python

How to write a fuzzing test suite in Python

## Installing atheris

`atheris` is a code fuzzing test suite written in Python and based on `LibFuzzer`. Install it using this command:

`pip3 install atheris`

Another option is to build it from the [atheris](https://github.com/google/atheris) repository

`pip3 install --no-binary atheris atheris`  
`git clone https://github.com/google/atheris.git`  
`cd atheris`  
`pip3 install .`  

## Instrumentation

Instrumentation can be done in different ways.

Using functions:

```python
@atheris.instrument_func
def my_function(foo, bar):
  print("instrumented")
```

Using modules:

```python
with atheris.instrument_imports():
  import foo
  from bar import baz
```

Using modules and functions:

```python
atheris.instrument_all()
atheris.Setup()
```

### Example 1: Division by zero

There is a function where division by zero never happens:

```python
def TestOneInput(data):
    
    if len(data) < 2:
        return 0

    a = data[0]
    b = data[1]

    c = a / (b - 30)

```

The fuzzing test suite for it looks like this:

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

### Example 2: Pillow ([CVE-2021-34552](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2021-34552))

CVE-2021-34552 is an instance of unsafe use of `sprintf` in a module written in C [_imaging_](https://github.com/python-pillow/Pillow/pull/5567/files). It results in stack overflow.

You can build Pillow with this command:

`git clone https://github.com/python-pillow/Pillow`  
`cd Pillow`  
`git checkout 8.2.0 && python3 ./setup.py build`  

That's what a fuzzing test suite looks like:

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

The `PIL` module is importen from a custom directory (not a system one) to keep the system clean.

You need any `.jpg` image to run it.

The `try except` block is required because the module will generate lots of exceptions which would stop the fuzzing process.

Run with this command:

`./pillow-fuzzer.py ./corpus -only_ascii=1`

The options are the same as in [`libfuzzer`](https://llvm.org/docs/LibFuzzer.html).

Here `corpus` is a corpus of starting test cases. Here's a simple option:

`echo 123 > corpus/123`

Use `-only_ascii=1` to generate test cases that only feature ASCII symbols as required by the tested function `_imaging.convert`.

