
# Rust

### cargo-fuzz (libFuzzer)

Для начала работы необходимо установить [cargo-fuzz](https://github.com/rust-fuzz/cargo-fuzz):

```bash
cargo install cargo-fuzz
```

В качестве примера можно использовать [rust-url](https://github.com/servo/rust-url.git) — URL библиотеку для Rust.

Необходимо склонировать репозиторий:

```bash
git clone https://github.com/servo/rust-url.git
```

Затем перейдя в директорию выполнить:

```bash
git checkout bfa167b4e0253642b6766a7aa74a99df60a94048
```

Чтобы перейти к конкретной ревизии, которая содержит ошибку синтаксического анализа.

После необходимо инициализировать `cargo-fuzz`:

```bash
cargo fuzz init
```

Появится директория `fuzz`, код фаззинг-теста необходимо поместить в `fuzz/fuzz_targets/fuzz_target_1.rs`:

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

Корпус в `fuzz/corpus/fuzz_target_1/`:

```bash
mkdir in
echo "tcp://example.com/" > in/url
echo "ssh://192.168.1.1" > in/url2
echo "http://www.example.com:80/foo?hi=bar" > in/url3
```

Запуск фаззинг-теста осуществляется следующей командой:

```bash
RUST_BACKTRACE=1 cargo fuzz run
```

Бинарный файл фаззинг-теста находится по следующему адресу: `rust-url/fuzz/target/x86_64-unknown-linux-gnu/release/fuzz_target_1`

Бинарный файл и корпус предстоит добавить в архив для последующей загрузки в BondiFuzz.

### AFL

Для начала работы с AFL-фаззером необходимо установить:

```bash
cargo install afl
```

Необходимо склонировать репозиторий:

```bash
git clone https://github.com/servo/rust-url.git
```

и также перейти к уязвимой ревизии.

Затем инициализировать:

```bash
cargo new --bin url-fuzz-target
```

Исходник с фаззинг-тестом должен находиться в `url-fuzz-target/src/main.rs`

В файл `url-fuzz-target/Cargo.toml` необходимо добавить следующие строки:

```
[dependencies]
afl = "*"
url = { path = ".."} // это путь к rust-url/ относительно rust-url/url-fuzz-target
```

Фаззинг-тест собирается следующей командой:

```bash
cargo afl build
```

Необходимо создать директорию `in`, где будет храниться тот же корпус, что был создан для libFuzzer-а.

Затем запускаем фаззинг-тест, предварительно перейдя в директорию `url-fuzz-target` командой:

```bash
cargo afl fuzz -i in -o out target/debug/url-fuzz-target
```

