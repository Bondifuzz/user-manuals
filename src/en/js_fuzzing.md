
# JavaScript

**JavaScript is not supported, but we are working on it.**

The `jsfuzz` [fuzzer](https://gitlab.com/gitlab-org/security-products/analyzers/fuzzers/jsfuzz) can be used to work with JavaScript code. It's similar but unrelated to `libfuzz`.

## Installation

To install `jsfuzz`, use this command:

`npm i -g jsfuzz`

## Options

Here are the options that can be used with `jsfuzz`:

* `dir` – one or several directories with the corpus
* `regression` – crash reproduction and recheck
* `exact-artifact-path` – path to save a crash
* `rss-limit-mb` – memory limit
* `timeout` – iteration timeout
* `versifier` – mutator for text protocols like xml, http, and json
* `only-ascii` – ascii test cases only
* `fuzzTime` – fuzzer operation time

## Code

Tested logic must be placed in the `fuzz(buf)` function:

```js
function fuzz(buf) {
  // call your package with buf  
}
module.exports = {
    fuzz
};

```

## Execution

Run `jsfuzz` using this command:

`jsfuzz your.js [options]`

## Example

This example is taken from the `jsfuzz` repo:

```js
const jpeg = require('jpeg-js');

function fuzz(buf) {
    try {
        jpeg.decode(buf);
    } catch (e) {
        // Those are "valid" exceptions. we can't catch them in one line as
        // jpeg-js doesn't export/inherit from one exception class/style.
        if (e.message.indexOf('JPEG') !== -1 ||
            e.message.indexOf('length octect') !== -1 ||
            e.message.indexOf('Failed to') !== -1 ||
            e.message.indexOf('DecoderBuffer') !== -1 ||
            e.message.indexOf('invalid table spec') !== -1 ||
            e.message.indexOf('SOI not found') !== -1) {
        } else {
            throw e;
        }
    }
}

module.exports = {
    fuzz
};

```