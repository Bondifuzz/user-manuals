
# Работа с CLI утилитой bondi-python

## Установка CLI утилиты

Длы работы потребуется Python 3.7 и выше.

Склонируйте проект:

```bash
git clone https://github.com/bondifuzz/bondi-python.git
```

Установите при помощи `pip`:

```bash
pip install bondi-python
```

После установки запустите с командой `--help`:

```bash
bondi --help
```

Автодополнение вводимых команд можно подключить при помощи дополнительного фреймворка командой:

```bash
bondi --install-completion
```

## Конфигурация (config)

Инициализация подключения к серверу:

```bash
bondi config init
```

Необходимо ввести URL сервера, имя пользователя и пароль.

```bash
Server url: https://demo.bondifuzz.com
Username: username
Password: ***
OK - Initialization successful
```
Подлючение можно обновить командой:

```bash
bondi config set username user_1
OK - Config updated successfully
```

Получение информации об уже установленном подключении:

```bash
bondi config show

--------  ------------------
url       demo.bondifuzz.com
username  **************name
password  **************4321
--------  ------------------
```
Получение URL сервера, к которому установлено подключение:

```bash
bondi config get url

https://demo.bondifuzz.com
```

Получение имени пользователя, аккаунт которого подключен к серверу:

```bash
bondi config get username
```

## Работа с проектами

Создание проекта:

```bash
bondi projects create
```

Необходимо указать название проекта (название должно быть уникальным), значения CPU и RAM. Проекту автоматически присваивается уникальное `id`.

```bash
Name: project_1
Node cpu: 40
Node ram: 360
----  ---------
id    10550740
name  project_1
----  ---------
```

Значение CPU в проекте измеряется в количестве ядер, и может принимать следующие значения: 2, 4, 6, 8, 10, 12, 14, 16, 20, 24, 28, 32, 36, 40, 44, 48, 52, 56, 60, 64, 68, 72, 76, 80, 84, 88, 92, 96. Для упрощения выбора значения можно воспользоваться клавишей `Tab`.

Значение RAM в проекте измеряется в GiB и равно значению CPU, умноженному на коэффициенты от 1 до 16, но не может быть более 640 GiB. Для упрощения выбора значения можно воспользоваться клавишей `Tab`.

Получение информации о проекте:

```bash
bondi projects get 10550740
```

Необходимо указать `id` проекта или его название.

```bash
-----  ---------
Project name    project_1
Description     Default project
Pool status     Ready
Node group      CPU per node: 4 cores, RAM per node: 8GB, Node count: 1
Pool resources  CPU in total: 3720 mcpu, RAM in total: 5714MB, Nodes ready: 1

-----  ---------
```

Получение списка проектов с присвоенными `id` и описаниями:

```bash
bondi projects list

+----------+--------------+------------------+
|       id | name         | brief            |
|----------+--------------+------------------|
| 10550740 | project_1    | My first project |
|  9845728 | project_2    | No description   |
|  8953832 | project_3    | No description   |
|  2755294 | default      | Default project  |
+----------+--------------+------------------+
```

Изменение названия проекта:

```bash
bondi projects update --id 10550740 --new-name project_2
```

В таблице выводится предыдущее название проекта и новое.

```bash
+------------+-----------+-----------+
| Property   | Old       | New       |
|------------+-----------+-----------|
| name       | project_1 | project_2 |
+------------+-----------+-----------+
```

Изменение описания проекта:

```bash
bondi projects update --id 10550740 --new-description no description
```

В таблице выводится предыдущее описание проекта и новое.

```bash
+-------------+-------+----------------+
| Property    | Old   | New            |
|-------------+-------+----------------|
| description | none  | no description |
+-------------+-------+----------------+
```

Для удобства работы есть возможность установить текущий проект как проект по умолчанию, в таком случае не будет необходимости вводить его название, оно будет подставляться утилитой автоматически.

```bash
bondi projects set-default project_1
```

Посмотреть проект, установленный по умолчанию, можно командой:

```bash
bondi projects get-default
```

Отменить назначение по умолчанию можно командой:

```bash
bondi projects unset-default
```

Проект можно переместить в корзину командой:

```bash
bondi projects delete project_1
```

Восстановление проекта из корзины:

```bash
bondi projects restore project_1
```

Проект можно удалить без возможности восстановления командой:

```bash
bondi projects erase project_1
```

## Работа с фаззерами

Создание фаззера:

```bash
bondi fuzzers create
```

При создании фаззера необходимо указать тип фаззера, язык программирования и проект, к которому будет относиться фаззер. Название фаззера должно быть уникальным в рамках проекта. Фаззеры, относящиеся к разным проектам, могут иметь одинаковые названия. Фаззеру автоматически будет присвоен уникальный `id`.

```bash
Name: fuzzer_1
Description: none
Fuzzer type: AFL
Fuzzer lang: Cpp
Project: project_2
----  --------
id    10591666
name  fuzzer_1
----  --------
```

Получение информации о фаззере:

```bash
bondi fuzzers get fuzzer_1
```

Будут выведены все данные о фаззере.

```bash
Fuzzer: fuzzer_1
--------------  --------
id              10591666
name            fuzzer_1
type            AFL
lang            Cpp
ci_integration  False
description     none
--------------  --------
```

Получение списка фаззеров, необходимо указать название проекта:

```bash
bondi fuzzers list
```

Список возможных конфигураций *язык программирования -- движок фаззера*:

```bash
bondi fuzzers show-configurations

------  --------------
C++     AFL, LibFuzzer
Go      LibFuzzer
Rust    LibFuzzer
Python  LibFuzzer
------  --------------
```

Изменение названия фаззера с указанием проекта, к которому он относится:

```bash
bondi fuzzers update fuzzer_1 -n fuzzer_2

Project: project_2
+-----------------+-------------+-------------+
| Property name   | Old value   | New value   |
|-----------------+-------------+-------------|
| Project name    | fuzzer_1    | fuzzer_2    |
+-----------------+-------------+-------------+
```

Изменение описания фаззера с указанием проекта, к которому он относится:

```bash
bondi fuzzers update fuzz1 -d nonono

Project: project_2
+-----------------+----------------+-------------+
| Property name   | Old value      | New value   |
|-----------------+----------------+-------------|
| Description     | No description | ololo       |
+-----------------+----------------+-------------+
```

Для удобства работы есть возможность установить текущий фаззер как фаззер по умолчанию, в таком случае не будет необходимости вводить его название, оно будет подставляться утилитой автоматически.

```bash
bondi fuzzers set-default fuzzer_1
```

Посмотреть фаззер, установленный по умолчанию, можно командой:

```bash
bondi fuzzers get-default
```

Отменить назначение по умолчанию можно командой:

```bash
bondi fuzzers unset-default
```

Фаззер можно переместить в корзину командой:

```bash
bondi fuzzers delete fuzzer_1
```

Восстановление фаззера из корзины:

```bash
bondi fuzzers restore fuzzer_1
```

Фаззер можно удалить без возможности восстановления командой:

```bash
bondi fuzzers erase fuzzer_1
```

Можно скачать корпус фаззера командой:

```bash
bondi fuzzers download-corpus fuzzer_1
```

## Создание версий фаззера

После создания фаззера необходимо создать его первую версию, а затем последующие. Это позволит не создавать каждый раз заново фаззер после внесения каких-либо изменений в тестируемый код и в фаззинг-тест для него. Каждой версии фаззера соответствует локально созданный пользователем фаззинг-тест. Максимальные значения приведены на проекта, создаваемого по-умолчанию.

Значение CPU измеряется в mcpu и может быть от 500 до 2000.

Значение RAM измеряется в MiB и может быть от 500 до 5000.

Значение tmpfs измеряется в MiB и может быть от 100 до 2000.

Пример команды для создания версии фаззера:

```bash
bondi revisions create -n revision_1 -i 53823967 -f fuzz1 -p project_1 --cpu 600 --ram 1000 --tmpfs 300

-------------  ----------
ID             64321403
Revision name  revision_1
-------------  ----------
```

Если не указать название версии в команде, оно сформируется автоматически. Также версии автоматически присваивается уникальный ID.

Список всех версий фаззера можно посмотреть командой:

```bash
bondi revisions list
```

Получение информации о конкретной версии фаззера:

```bash
bondi revisions get revision_1 -f fuzzer_1
```

Для удобства работы есть возможность установить текущую версию как версию по умолчанию, в таком случае не будет необходимости вводить ее название, оно будет подставляться утилитой автоматически.

```bash
bondi revisions set-default revision_1
```

Посмотреть версию, установленную по умолчанию, можно командой:

```bash
bondi revisions get-default
```

Отменить назначение по умолчанию можно командой:

```bash
bondi revisions unset-default
```

Версию можно переместить в корзину командой:

```bash
bondi revisions delete revision_1
```

Восстановление версии фаззера из корзины:

```bash
bondi revisions restore revision_1
```

Версию можно удалить без возможности восстановления командой:

```bash
bondi revisions erase revision_1
```

Корпуса фаззеров можно копировать между версиями одного фаззера командой:

```bash
bondi revisions copy-corpus revision_1 revision_2
```

Копировать корпус можно только в версию, которая ранее не запускалась.

## Базовые образы

Для каждого фаззера необходимо выбрать образ операционной системы, в зависимости от того в какой он запускались локально фаззинг-тесты. Посмотреть доступные образы можно следующей командой:

```bash
bondi images list-available -l Cpp -e LibFuzzer -p project_1
```

Каждому образу соответствует уникальный ID.

На данный момент только администраторы BondiFuzz могут загружать новые образы, у пользователя есть возможность через техподдержку отправить запрос на необходимый образ. В будущем планируется добавить такую возможность и для пользователей платформы.

## Загрузка фаззинг-тестов

Предварительно созданные и проверенные на работоспособность файлы фаззинг-тестов загружаются пользователем в созданные фаззеры следующей командой:

```bash
bondi revisions upload-files -p project_1 -f fuzzer_1 revision_1 --binaries-path path_to_fuzzer/binaries.tar.gz --config-path path_to_fuzzer/config.json --seeds-path path_to_fuzzer/seeds.tar.gz

binaries  [####################################]  100%
seeds  [####################################]  100% 
config  [####################################]  100%
OK - Files uploaded successfully
```

Для удобства можно перейти в директорию с файлами фаззинг-теста и использовать более простую команду:

```bash
bondi revisions upload-files -p project_1 -f fuzzer_1 revision_1 --binaries binaries.tar.gz --config config.json --seeds seeds.tar.gz
```

Скачать загруженные файлы фаззинг-теста:

```bash
bondi revisions download-files revision_1 -f fuzz11 -p default
```

## Работа с фаззинг-тестами

Фаззинг-тест запускается командой:

```bash
bondi revisions start revision_1
```

Если все хорошо, появится сообщение: `OK - Revision started`

Важный момент: архитектура BondiFuzz такова, что запускается именно фаззинг-тест. Невозможно запустить одновременно несколько версий фаззинг-тестов, но могут одновременно работать фаззинг-тесты, относящиеся к разным фаззерам.

Фаззинг-тест останавливается командой:

```bash
bondi revisions stop revision_1
```

Фаззинг-тест перезапускается командой:

```bash
bondi revisions restart revision_1
```

При перезапуске фаззинг-теста сбрасываются все данные, остается только корпус.

Корпуса можно копировать из одного фаззинг-теста в другой командой:

```bash
bondi revisions copy-corpus revision_1 revision_2
```

## Результаты работы фаззинг-тестов

Получение списка крэшей для всех версий фаззинг-тестов, в которых они обнаружены, необходимо указать соответствующий проект:

```bash
bondi crashes list -f my_fuzzer -p project_1
```

или

```bash
bondi crashes list
```

Также можно получить список крэшей, относящихся к определенной версии фаззинг-теста:

```bash
bondi crashes list -r revision_1
```

Для получения конкретной информации о крэше, необходимо ввести ID крэша, название фаззера, которым он обнаружен, и соответствующий проект:

```bash
bondi crashes get 10327133 -f my_fuzzer -p project_1
```

Получение детальной информации о крэше, необходимо ввести ID крэша, название фаззера, в котором он обнаружен, и соответствующий проект:

```bash
bondi crashes get-details 10327133 -f my_fuzzer -p project_1
```

Вывод будет следующим:

```bash
INFO: Seed: 3128728610
INFO: Loaded 1 modules   (35943 inline 8-bit counters): 35943 [0xad8690, 0xae12f7), 
INFO: Loaded 1 PC tables (35943 PCs): 35943 [0x94f0e8,0x9db758), 
/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer: Running 1 inputs 2000000 time(s) each.
Running: /mnt/tempfs/binaries/leak-56aa9f9652536ca63aa8251540ae7007a017c735
==16==WARNING: invalid path to external symbolizer!
==16==WARNING: Failed to use and restart external symbolizer!

=================================================================
==16==ERROR: LeakSanitizer: detected memory leaks

Direct leak of 32 byte(s) in 1 object(s) allocated from:
    #0 0x52447d  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x52447d)
    #1 0x6013fb  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x6013fb)
    #2 0x6588c1  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x6588c1)
    #3 0x56afb8  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x56afb8)
    #4 0x55c810  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x55c810)
    #5 0x59f242  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x59f242)
    #6 0x59a1d1  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x59a1d1)
    #7 0x556bcd  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x556bcd)
    #8 0x45d7c1  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x45d7c1)
    #9 0x448ed2  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x448ed2)
    #10 0x44ef3e  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x44ef3e)
    #11 0x476a02  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x476a02)
    #12 0x7f38ee67ed09  (/lib/x86_64-linux-gnu/libc.so.6+0x26d09)

Indirect leak of 32 byte(s) in 1 object(s) allocated from:
    #0 0x52447d  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x52447d)
    #1 0x6013fb  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x6013fb)
    #2 0x6588e1  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x6588e1)
    #3 0x56afb8  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x56afb8)
    #4 0x55c810  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x55c810)
    #5 0x59f242  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x59f242)
    #6 0x59a1d1  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x59a1d1)
    #7 0x556bcd  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x556bcd)
    #8 0x45d7c1  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x45d7c1)
    #9 0x448ed2  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x448ed2)
    #10 0x44ef3e  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x44ef3e)
    #11 0x476a02  (/mnt/tempfs/binaries/openssl-1.0.1f-fsanitize_fuzzer+0x476a02)
    #12 0x7f38ee67ed09  (/lib/x86_64-linux-gnu/libc.so.6+0x26d09)

SUMMARY: AddressSanitizer: 64 byte(s) leaked in 2 allocation(s).

INFO: a leak has been found in the initial corpus.

INFO: to ignore leaks on libFuzzer side use -detect_leaks=0.
```

Для скачивания данных крэша необходимо ввести ID крэша, название фаззера, в котором он обнаружен, и соответствующий проект:

```bash
bondi crashes download -c 10327133 -f my_fuzzer -p project_1
```

Вся информация будет сохранена в файл формата .crash.

```bash
crash  [####################################]  100%
OK - Saved to 10327133.crash  
```

## Просмотр статистики

В BondiFuzz ведется подсчет статистики по работе фаззинг-тестов. 

Статистику по работе конкретного фаззинг-теста можно посмотреть командой:

```bash
bondi statistics show -r revision_1 -f fuzzer_1 -p project_1
```

Для более подробной статистики можно посмотреть графики по каждому из следующих параметров:

- corpus_entries
- edge_cov
- execs_per_sec
- known_crashes
- unique_crashes
- corpus_size
- execs_done
- feature_cov
- peak_rss

```bash
bondi statistics show-chart -c unique_crashes -r revision_1 -f fuzzer_1 -p project_1
```

## Создание интеграций с трекерами задач

CLI-утилита bondi-python предполагает возможность создания интеграций с трекерами задач.

Для создания интеграции с Jira необходимо указать URL-адрес, логин/почту пользователя, пароль/токен пользователя, название проекта в Jira, тип issue, приоритет, название интеграции (должно быть оригинальным), тип интеграции, название проекта в BondiFuzz.

```bash
bondi integrations create --jira-url https://demo.jira.com --jira-username User@user.com --jira-password passw123 --jira-project MP --jira-issue-type Task --jira-priority Medium -n integration_1 -t Jira -p project_1
```

Интеграции будет присвоено уникальный ID.

Удаление интеграции осуществляется следующей командой:

```bash
bondi integrations delete -p project_1 integration_1
```

Интеграцию можно отключить следующей командой, указав проект в BondiFuzz и ID/название интеграции.

```bash
bondi integrations disable -p project_1 integration_1
```

Отключенную интеграцию можно включить, указав проект в BondiFuzz и ID/название интеграции:

```bash
bondi integrations enable -p project_1 integration_1
```

Для получения детальной информации об интеграции необходимо указать ID/название интеграции и соответствующий проект:

```bash
bondi integrations get -p project_1 17924052
```

Для получения детальной информации об интеграции необходимо указать ID/название интеграции и соответствующий проект:

```bash
bondi integrations get-config -p project_1 17924052
```

Получение списка интеграций по названию проекта:

```bash
bondi integrations list -p project_1
```

Изменение названия интеграции осуществляется следующей командой:

```bash
bondi integrations update -p project_1 17924052 -n integration_2
```
