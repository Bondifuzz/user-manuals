
# Example of creating fuzzing test suite

For demonstration, we will use a fuzzing test suite for the notorious [Heartbleed](https://en.wikipedia.org/wiki/Heartbleed) vulnerability from [Fuzzer Test Suite](https://github.com/google/fuzzer-test-suite). (See appendix)

## Binary file

After compilation we get the fuzzing test suite's binary. It will have a default name, but for convenience we can rename it as `target`.

Upload the archive with fuzzing test suite files to the fuzzing farm.

`cd path_to_fuzzer`  
`tar -czf binaries.tar.gz openssl-1.0.1f-fsanitize_fuzzer`

In the case of Heartbleed, we have to add a folder with keys to the archive. 

## Config file

You can upload `config.json` with additional options to the farm.

```
{
    "target" : {
        "path": "openssl-1.0.1f-fsanitize_fuzzer"
    }
    "options": {
        "libfuzzer": {
             ...
        }
    }
}
```

## Seeds file

Seeds must be archived without placing them in a folder. 

`cd path_to_seeds`  
`tar -czf seeds.tar.gz seed1 seed2`

## Execution

Upload these files to the farm and select the Ubuntu image.