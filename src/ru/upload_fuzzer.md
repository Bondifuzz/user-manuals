
# Пример создания фаззинг-теста Libfuzzer

В качестве примера возьмём фаззинг-тест для известной уязвимости [Heartbleed](https://en.wikipedia.org/wiki/Heartbleed) из [Fuzzer Test Suite](https://github.com/google/fuzzer-test-suite). (См. приложение)

## Бинарный файл

После компиляции получаем непосредственно файл фаззинг-теста. Фаззинг-тест будет назван по-умолчанию, но для последующего удобства это имя можно изменить на `target`.

BondiFuzz предполагает загрузку файлов фаззинг-теста в виде архива.

```bash
cd path_to_fuzzer
tar -czf binaries.tar.gz openssl-1.0.1f-fsanitize_fuzzer runtime
```

В случае с Heartbleed в архив нужно поместить папку с файлами ключей. 

## Конфигурационный файл

В ферму также можно загрузить конфигурационный файл `config.json` с дополнительными опциями.

```json
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

## Файлы с сидами

Сиды — набор входных данных для фаззинг-теста — нужно добавить в архив, не помещая их в директорию.

```bash
cd path_to_seeds
tar -czf seeds.tar.gz seed1 seed2
```

## Запуск фаззинг-теста

Эти файлы необходимо загрузить в BondiFuzz, предварительно выбрав образ из доступных на данный момент.
