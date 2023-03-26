
# Go

Использование go-fuzz в режиме `libfuzzer`

## Установка

```bash
export GO111MODULE=on
go get github.com/dvyukov/go-fuzz/go-fuzz-build
go get github.com/dvyukov/go-fuzz/go-fuzz
```

## Пример 1: Hello, Fuzzer! (тестируем на наличие ошибки типа DivZero)

В качестве простого примера будет деление на ноль.

Потребуется верия go - `go1.18.2 linux/amd64`.

В файл `your_path/fuzz.go` записываем следующий код:

```go
package zero

func Fuzz(data []byte) int {

	if len(data) < 10{
		return 0
	}

	a := data[0]
	b := data[1]
	c := a / (b-100)

	_ = c

	return 0
}
```

Сборка:

```bash
go-fuzz-build -libfuzzer -func=Fuzz -o zero.a
clang -fsanitize=fuzzer zero.a -o divzero-fuzzer
```

Опции для `go-fuzz-build`:

* `-libfuzzer` - включение режима `libfuzzer`
* `-func=Fuzz` - определение функции, которая будет подвергнута фаззингу, в данном случае - `Fuzz`
* `-o zero.a` - название статической библиотеки, в которой будет находиться скомпилированный код, название произвольное

Опции для `clang`:

* `-fsanitize=fuzzer` - включение режима фаззинга, чтобы компилятор поддтянул все зависимости для `libfuzzer`
* `zero.a` - библиотека, где находится логика фаззинг-теста
* `-o divzero-fuzzer` - название фаззинг-теста

Запуск:

```bash
./divzero-fuzzer
```

## Пример 2: Тестируем внутреннии функции Hashicorp Vault

На основе [этой](https://adalogics.com/blog/getting-started-with-go-fuzz) статьи. Цель - [Vault](https://github.com/hashicorp/vault) -- инструмент для безопасного доступа к секретной информации, функция `XORBase64`.

Необходимая версия go - `go1.18.2 linux/amd64`.

Устанавливаем `vault`:

```bash
export GO111MODULE=on
go get github.com/hashicorp/vault
cd $GOPATH/src/github.com/hashicorp/vault/sdk/helper/xor
```

Записываем в файл `fuzz.go` следующий код:

```go
package xor

func Fuzz(data []byte) int {
    _, _ = XORBase64(string(data), string(data))
    return 1
}
```

Название пакета такое же, как в `xor.go`, в котором `XORBase64`.

Сборка:

```bash
go-fuzz-build -libfuzzer -func=Fuzz -o Fuzz.a
clang -fsanitize=fuzzer Fuzz.a -o xor-fuzzer
```

Запуск:

```bash
./xor-fuzzer
```

## Пример 3: Тестируем DNS-библиотеку

На основе [статьи](https://blog.cloudflare.com/dns-parser-meet-go-fuzzer/).

Цель - [DNS-библиотека](https://github.com/miekg/dns) версии `v1.1.25`, функции `Unpack`, `PackBuffer`.

Версия go - `go1.13.8 linux/amd64`.

Установка:

```bash
export GO111MODULE=on
go mod init fuzz
go get github.com/miekg/dns@v1.1.25
```

Команда `go mod init` необходима, чтобы можно было скачать определенную версию репозитория.

Записываем в файл `fuzz.go` следующий код:

```go
package fuzz

import	(
	"github.com/miekg/dns"
    "bytes"
    "encoding/hex"
    "os"
)

func Fuzz(rawMsg []byte) int {
    var (
        msg         = &dns.Msg{}
        buf, bufOne = make([]byte, 100000), make([]byte, 100000)
        res, resOne []byte

        unpackErr, packErr error
    )

    if unpackErr = msg.Unpack(rawMsg); unpackErr != nil {
        return 0
    }

    if res, packErr = msg.PackBuffer(buf); packErr != nil {
        return 0
    }

    for i := range res {
        bufOne[i] = 1
    }

    resOne, packErr = msg.PackBuffer(bufOne)
    if packErr != nil {
        println("Pack failed only with a filled buffer")
        panic(packErr)
    }

    if !bytes.Equal(res, resOne) {
        println("buffer bits leaked into the packed message")
        println(hex.Dump(res))
        println(hex.Dump(resOne))
        os.Exit(1)
    }

    return 1
}
```

Сборка:

```bash
go-fuzz-build -libfuzzer -func=Fuzz -o Fuzz.a
clang -fsanitize=fuzzer Fuzz.a -o dns-fuzzer
```

### Создание корпуса

Прежде чем запустить фаззинг-тест, необходимо создать корпус.

На основе дампа [Network_Join_Nokia_Mobile.pcap](https://github.com/miekg/pcap/blob/master/test/pcap_files/Network_Join_Nokia_Mobile.pcap).

Скачиваем дамп:

```bash
mkdir corpus
cd corpus
git clone https://github.com/miekg/pcap
```

Записываем в файл `corpus/gen_corp.go` следующий код:

```go
package main

import (
	"crypto/rand"
	"encoding/hex"
	"log"
	"os"
	"strconv"
	"github.com/miekg/pcap"
)

func fatalIfErr(err error) {
	if err != nil {
		log.Fatal(err)
	}
}

func main() {
	handle, err := pcap.OpenOffline(os.Args[1])
	fatalIfErr(err)

	b := make([]byte, 4)
	_, err = rand.Read(b)
	fatalIfErr(err)
	prefix := hex.EncodeToString(b)

	i := 0
	for pkt := handle.Next(); pkt != nil; pkt = handle.Next() {
		pkt.Decode()

		f, err := os.Create("p_" + prefix + "_" + strconv.Itoa(i))
		fatalIfErr(err)
		_, err = f.Write(pkt.Payload)
		fatalIfErr(err)
		fatalIfErr(f.Close())

		i++
	}
}

```

Сборка:

```bash
export GO111MODULE=on
go get github.com/miekg/pcap
go build gen_corp.go
```

Генерация корпусов:

```bash
mkdir in
cd in
../gen_corp ../pcap/test/pcap_files/Network_Join_Nokia_Mobile.pcap
```

Запуск фаззинг-теста со сгенерированными корпусами:

```bash
./dns-fuzzer ./corpus/in
```

## Какие могут возникнуть проблемы

### crypto/elliptic

Если у вас версия `go 1.18.x`, и у исследуемого кода есть зависимость от `crypto/elliptic`, то ничего не выйдет. необходимо ждать, когда закроют это [issue](https://github.com/dvyukov/go-fuzz/issues/338).

### Версия модуля

Если нужна конкретная версия модуля, то сначала необходимо проверить есть ли эта версия на [pkg.go.dev](https://pkg.go.dev/). Например:

- https://pkg.go.dev/github.com/artyom/mdserver?tab=versions - у `github.com/artyom/mdserver` все в порядке
- https://pkg.go.dev/github.com/istio/istio?tab=versions - у `github.com/istio/istio` не в порядке, ничего не выйдет.

### GO111MODULE

Если не удается скачать модуль, необходимо проверить, что `GO111MODULE=on`.
