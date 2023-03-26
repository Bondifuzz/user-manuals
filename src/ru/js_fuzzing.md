
# JavaScript

(Поддержка языка JavaScript находится в разработке.)

Для фаззинга кода на JavaScript применим [фаззер](https://gitlab.com/gitlab-org/security-products/analyzers/fuzzers/jsfuzz) `jsfuzz`. Имеет сходство с `libfuzzer`, но не имеет к нему отношения.

## Установка

Установка осуществляется командой:

```bash
npm i -g jsfuzz
```

## Опции

Для работы с `jsfuzz` могут быть применены следующие опции:

* `dir` - одна или несколько директорий с корпусом
* `regression` - воспроизведение, проверка крэшей
* `exact-artifact-path` - мосто, куда сохранится крэш
* `rss-limit-mb` - ограничение по памяти
* `timeout` - таймаут на итерацию
* `versifier` - мутатор для текстовых протоколов типа xml, http, json
* `only-ascii` - только ascii тест-кейсы
* `fuzzTime` - время работы фаззинг-теста

## Код

Исследуемая логика должна находиться в функции `fuzz(buf)`:

```js
function fuzz(buf) {
  // call your package with buf  
}
module.exports = {
    fuzz
};

```

## Запуск

Запуск осуществляется командой:

```bash
jsfuzz your.js [options]
```

## Пример 1: фаззинг-тест для парсера jpeg

Пример взят из репозитория `jsfuzz`:

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
