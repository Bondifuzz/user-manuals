
# C++

You can use [LibFuzzer](https://llvm.org/docs/LibFuzzer.html) to fuzz C++ code. It's a library meant for fuzzing other libraries distributed with Clang, a project by LLVM.

## Heartbleed example

As an example, let's take the famous [heartbleed](https://en.wikipedia.org/wiki/Heartbleed) vulnerability found in [OpenSSL](https://en.wikipedia.org/wiki/OpenSSL).

First, we have to install the vulnerable version of the library.

`curl -O https://ftp.openssl.org/source/old/1.0.1/openssl-1.0.1f.tar.gz`  
`tar xf openssl-1.0.1f.tar.gz`  
`cd openssl-1.0.1f/`  
`./config`  
`make CC="/usr/local/bin/clang -g -fsanitize=address,fuzzer-no-link"`  
`cd ..`  

The fuzzing test suite looks like this:

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
The files `server.key` and `server.pem` are generated using the following command:

`openssl req -x509 -newkey rsa:512 -keyout server.key -out server.pem -days 9999 -nodes -subj /CN=a/`

Here's the content of `CMakeLists.txt`:

```
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

Now, it's time to build and run the fuzzuer:

`mkdir -p build`  
`rm -rf build/*`  
`cd build`  
`cmake ..`  
`make`  
`./heartbleed_fuzzer`  