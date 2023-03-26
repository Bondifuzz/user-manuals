
# C++

Для фаззинга кода на языке C++ можно использовать [LibFuzzer](https://llvm.org/docs/LibFuzzer.html) — инструмент для фаззинга библиотек, распространяемую вместе с Clang, проект LLVM.

## Пример 1: Фаззинг-тест для уязвимости Heartbleed (CVE-2014-0160)

В качестве примера фаззинг-теста рассмотрим широко известную уязвимость [heartbleed](https://en.wikipedia.org/wiki/Heartbleed), обнаруженную в [OpenSSL](https://github.com/openssl/openssl).

Для начала работы необходимо установить уязвимую версию библиотеки.

```bash
curl -O https://ftp.openssl.org/source/old/1.0.1/openssl-1.0.1f.tar.gz
tar xf openssl-1.0.1f.tar.gz
cd openssl-1.0.1f/
./config
make CC="/usr/local/bin/clang -g -fsanitize=address,fuzzer-no-link"
cd ..
```

Сам фаззинг-тест будет иметь следующий вид:

```cpp
#include "openssl/ssl.h"
#include "openssl/err.h"
#include <assert.h>
#include <stdint.h>
#include <stddef.h>

SSL_CTX *Init() {
  SSL_library_init();
  SSL_load_error_strings();
  ERR_load_BIO_strings();
  OpenSSL_add_all_algorithms();
  SSL_CTX *sctx;
  assert (sctx = SSL_CTX_new(TLSv1_method()));
  assert(SSL_CTX_use_certificate_file(sctx, "../runtime/server.pem",
                                      SSL_FILETYPE_PEM));
  assert(SSL_CTX_use_PrivateKey_file(sctx, "../runtime/server.key",
                                     SSL_FILETYPE_PEM));
  return sctx;
}
extern "C" int LLVMFuzzerTestOneInput(const uint8_t *Data, size_t Size) {
  static SSL_CTX *sctx = Init();
  SSL *server = SSL_new(sctx);
  BIO *sinbio = BIO_new(BIO_s_mem());
  BIO *soutbio = BIO_new(BIO_s_mem());
  SSL_set_bio(server, sinbio, soutbio);
  SSL_set_accept_state(server);
  BIO_write(sinbio, Data, Size);
  SSL_do_handshake(server);
  SSL_free(server);
  return 0;
}
```

Файлы `server.key` и `server.pem` создаются следующей командой:

```bash
openssl req -x509 -newkey rsa:512 -keyout server.key -out server.pem -days 9999 -nodes -subj /CN=a/
```

Содержимое `CMakeLists.txt`:

```cpp
project("heartbleed-fuzzer")

set(CMAKE_CXX_COMPILER "clang++")

set(SRC "~/heartbleed")
set(OPENSSL_PATH ${SRC}/openssl-1.0.1f)

add_executable(heartbleed_fuzzer heartbleed.cpp)

target_include_directories(heartbleed_fuzzer PRIVATE ${OPENSSL_PATH}/include)
target_compile_options(heartbleed_fuzzer PRIVATE -fsanitize=fuzzer,address)

target_link_options(heartbleed_fuzzer PRIVATE -fsanitize=fuzzer,address)
target_link_libraries(heartbleed_fuzzer ${OPENSSL_PATH}/libssl.a ${OPENSSL_PATH}/libcrypto.a)
```

### Сборка и запуск фаззинг-теста

Сборка и запуск фаззинг-теста осуществляется следующими командами:

```bash
mkdir -p build  
rm -rf build/*  
cd build
cmake ..
make
./heartbleed_fuzzer
```
