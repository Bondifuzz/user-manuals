
# Go

Using go-fuzz in `libfuzzer` mode

## Installation

Run this commands:

`export GO111MODULE=on`  
`go get github.com/dvyukov/go-fuzz/go-fuzz-build`  
`go get github.com/dvyukov/go-fuzz/go-fuzz`  

### Example 1: Low difficulty

Let's consider division by zero as an example.

Required version of go: `go1.18.2 linux/amd64`.

Write the following code to `your_path/fuzz.go`:

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

Build:

`your_path$ go-fuzz-build -libfuzzer -func=Fuzz -o zero.a`  
`your_path$ clang -fsanitize=fuzzer zero.a -o divzero-fuzzer`  

Options for `go-fuzz-build`:

* `-libfuzzer` - enable `libfuzzer` mode
* `-func=Fuzz` - define a function that will be subject to fuzzing(in this case it's `Fuzz`)
* `-o zero.a` - name of a static library storing the compiled code (arbitrary name)

Options for `clang`:

* `-fsanitize=fuzzer` - enable a fuzzing mode in which the compiler will include all dependencies for `libfuzzer`
* `zero.a` - library with the fuzzing test suite's logic
* `-o divzero-fuzzer` - fuzzing test suite name

Run with this command:

`your_path$ ./divzero-fuzzer`

### Example 2: Medium difficulty

This example is based on [this](https://adalogics.com/blog/getting-started-with-go-fuzz) article. The target is [Vault](https://github.com/hashicorp/vault), a tool for secure access to classified data (function `XORBase64`).

Required version of go: `go1.18.2 linux/amd64`.

Install `vault`:

`export GO111MODULE=on`  
`go get github.com/hashicorp/vault`  
`cd $GOPATH/src/github.com/hashicorp/vault/sdk/helper/xor`  

Write the following code to `fuzz.go`:

```go
package xor

func Fuzz(data []byte) int {
    _, _ = XORBase64(string(data), string(data))
    return 1
}
```

The package name is the same as in `xor.go` with `XORBase64`.

Build:

`sdk/helper/xor$ go-fuzz-build -libfuzzer -func=Fuzz -o Fuzz.a`  
`sdk/helper/xor$ clang -fsanitize=fuzzer Fuzz.a -o xor-fuzzer`  

Run with this command:

`sdk/helper/xor$ ./xor-fuzzer`

### Example 3: Medium difficulty [2]

This is based on this [article](https://blog.cloudflare.com/dns-parser-meet-go-fuzzer/).

The target is the [DNS library](https://github.com/miekg/dns) `v1.1.25` and its functions `Unpack` and `PackBuffer`.

Required version of go: `go1.13.8 linux/amd64`.

Install:

`your_path$ export GO111MODULE=on`  
`your_path$ go mod init fuzz`  
`your_path$ go get github.com/miekg/dns@v1.1.25`  

The `go mod init` command is required to download a specific versions of the repository.

Write the following code to `fuzz.go`:

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

Build:

`your_path$ go-fuzz-build -libfuzzer -func=Fuzz -o Fuzz.a`  
`your_path$ clang -fsanitize=fuzzer Fuzz.a -o dns-fuzzer`  

## Corpus

Before running a fuzzing test suite, you have to create a corpus.

This is based on the dump [Network_Join_Nokia_Mobile.pcap](https://github.com/miekg/pcap/blob/master/test/pcap_files/Network_Join_Nokia_Mobile.pcap).

Clone the dump:

`mkdir corpus`  
`cd corpus`  
`git clone https://github.com/miekg/pcap`  

Write the following code to `corpus/gen_corp.go`:

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

Build:

`corpus$ export GO111MODULE=on`  
`corpus$ go get github.com/miekg/pcap`  
`corpus$ go build gen_corp.go`  

Corpus generation:

`corpus$ mkdir in`  
`corpus$ cd in`  
`corpus$ ../gen_corp ../pcap/test/pcap_files/Network_Join_Nokia_Mobile.pcap`  

Run the fuzzing test suite with the generated corpus:

`./dns-fuzzer ./corpus/in`

## Possible problems

### crypto/elliptic

If you are using `go 1.18.x` and the subject code has a `crypto/elliptic` dependency, nothing would work. You'll have to wait until they resolve this [issue](https://github.com/dvyukov/go-fuzz/issues/338).

### Module version

If you need a specific version, first check if it can be found at [pkg.go.dev](https://pkg.go.dev/).

For example, 

https://pkg.go.dev/github.com/artyom/mdserver?tab=versions - it's OK in `github.com/artyom/mdserver`,

https://pkg.go.dev/github.com/istio/istio?tab=versions - but not in `github.com/istio/istio`, so it wouldn't work.

### GO111MODULE

If you cannot download a module, check that `GO111MODULE=on`.
