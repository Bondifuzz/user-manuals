
# Rust

How to write a fuzzing test suite in Rust.

## Example 1: cargo-fuzz (libFuzzer)

First, install [cargo-fuzz](https://github.com/rust-fuzz/cargo-fuzz):

`cargo install cargo-fuzz`

You can use [rust-url](https://github.com/servo/rust-url.git), a URL library for Rust.

Clone the repository:

`git clone https://github.com/servo/rust-url.git`

And run this command:

`git checkout bfa167b4e0253642b6766a7aa74a99df60a94048`,

to go to a specific revision that has a syntax analysis error.

Then, initialize `cargo-fuzz`:

`cargo fuzz init`

A directory called `fuzz` will be created. Place the fuzzing test suite's code to `fuzz/fuzz_targets/fuzz_target_1.rs`:

```rust
#![no_main]
#[macro_use] extern crate libfuzzer_sys;
extern crate url;

fuzz_target!(|data: &[u8]| {
    if let Ok(s) = std::str::from_utf8(data) {
        let _ = url::Url::parse(s);
    }
});
```

and corpus to `fuzz/corpus/fuzz_target_1/`:

`mkdir in`
`echo "tcp://example.com/" > in/url`
`echo "ssh://192.168.1.1" > in/url2`
`echo "http://www.example.com:80/foo?hi=bar" > in/url3`

Use this command to run the fuzzing test suite:

`RUST_BACKTRACE=1 cargo fuzz run`

The fuzzing test suite's binary can be found here: `rust-url/fuzz/target/x86_64-unknown-linux-gnu/release/fuzz_target_1`

You have to compress the binary and the corpus into an archive which you will upload to BondiFuzz.

## Example 2: AFL

To start working with the AFL-fuzzer install:

`cargo install afl`

Clone:

`git clone https://github.com/servo/rust-url.git`

and go to a vulnerable revision.

Then, initialize:

`cargo new --bin url-fuzz-target`

The source with the fuzzing test suite has to be here `url-fuzz-target/src/main.rs`

Add the following strings to `url-fuzz-target/Cargo.toml`:

```
[dependencies]
afl = "*"
url = { path = ".."} // это путь к rust-url/ относительно rust-url/url-fuzz-target
```

Build the fuzzing test suite:

`cargo afl build`

Create a directory called `in` where you will store the corpus used for libFuzzer.

Run the fuzzing test suite first going to the directory `url-fuzz-target`:

`cargo afl fuzz -i in -o out target/debug/url-fuzz-target`
