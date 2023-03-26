# Examples of fuzzing test suite

To better understand how to work in the fuzzing farm, we can take an existing fuzzing test suite that will definitely find some errors.

## Uploading files to BondiFuzz

You need to upload a binary file and, if you have them, seeds and config files.

### Binary

After compilation, we get the fuzzing test suite's binary. It will be named by default, but we can change its name to `target` for convenience.

Fuzzing test suite files are uploaded in archives.

`cd path_to_fuzzer`  
`tar -czf binaries.tar.gz fuzzgoat`  

### Config file

You can also upload a config file `config.json` with additional options.

```
{
    "target" : {
        "path": "my_fuzzer",
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

### Seed files

Seeds have to be archived without being placed in a folder. 

`cd path_to_seeds`  
`tar -czf seeds.tar.gz seed1 seed2`  

## Running a fuzzing test suite in BondiFuzz

Upload these files to the fuzzing farm. First, you have to choose an available Ubuntu image. It has to be the same version as the one used on your local machine during compilation.