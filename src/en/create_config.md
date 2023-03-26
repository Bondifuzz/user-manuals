
# Creating a fuzzing test suite config file

A configuration file is an auxiliary file woth additional options necessary for the correct operation of a fuzzing test suite.

## AFL fuzzing test suite example

Here's an example of a config file for an AFL fuzzer:

```
{
    "target": {
        "path": "url-fuzz-target",
    },
    "env": {
        "MY_ENV": "val"
    },
    "options": {
        "afl": {
            "min_length": 50,
        }
    }
}
```

`target` — path to the fuzzing test suite's binary.

Options:

`mode` — fuzzer's mode. Currently, BondiFuzz only supports Normal.

`schedule` — algorithms for assessing inout data that allow us to understand what to mutate to get input that increases code coverage. [Read more about it here](https://aflplus.plus/docs/power_schedules/).

`dict` — dictionary that sometimes will provide values instead of random mutations.

`file_extension` — if the fuzzing test suite's binary receives file paths as input, you can specify the file extension here.

`min_length` — minimum input length.

`max_length` — maximum input length.

`queue_selection` — in AFL, all input is queued; with this option you can choose the order: by weight or by position in the queue.

`python_module` — AFL allows you to write a module in Python and use it as a mutator. [Read more about it here](https://aflplus.plus/docs/custom_mutators/).

`custom_mutator_library` — custom library what will be used as a mutator. [Read more about it here](https://aflplus.plus/docs/custom_mutators/).

`custom_mutator_only` — all calls will be processed by the module/library from the options above.

`hang_timeout` — after this period, input is deemed as a hang.

`map_size` — the size of the array that stores code coverage information.

## Preloading libraries for AFL

`AFL-PRELOAD` is a way to upload a library to a binary. `AFL_PRELOAD` is required when the fuzzing test suite uses external dependencies and you need to upload libraries to a specified path. For example:

`AFL_PRELOAD=/path/to/libcompcov.so`

## LibFuzzer config file

Here's an example of a config file for LibFuzzer:

```
{
    "target" : {
        "path": "my_binary",
    }
    "env": {
        "MY_ENV": "val"
    },
    "options": {
        "libfuzzer": {
            "max_len": "512"
        },
    }
}
```

`target` — path to the fuzzing test suite's binary file.

Options:

`max_len` — maximum inout length.

`dict` — dictionary that is used for seeds.

`prefer_small` — if it equals 1, smaller input is prefered.

`timeout` — timeout in seconds.

`report_slow_units` — upon reaching this threshold input will be interpreted as invalid.

`only_ascii` — if it equals 1, only ASCII input is received.

`detect_leaks` — if it equals 1, the fuzzer attempts to detect data leaks.

`len_control` — defines how fast the length limit is extended.

`mutate_depth` — number of mutations for input data.

You can find more options [here](https://llvm.org/docs/LibFuzzer.html#options).

## Preloading libraries for LibFuzzer

`LD_PRELOAD` — is a way to upload a library to a binary. `LD_PRELOAD` is required when the fuzzing test suite uses external dependencies and you need to upload libraries to a specified path. For example:

`LD_PRELOAD": "./libs/libarchive.so.13 ./libs/libicudata.so.60 ./libs/libicuuc.so.60 ./libs/liblzo2.so.2 ./libs/libxml2.so.2`

If you don't want to list all libraries, use `LD_LIBRARY_PATH` to provide the path to the folder with them. For example:

`LD_LIBRARY_PATH": "./libs`