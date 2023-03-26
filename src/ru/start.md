
# Начало работы

Перед началом работы необходимо пройти аутентификацию. Для этого необходимо ввести логин пользователя и его пароль, полученные от администратора BondiFuzz, затем пароль можно изменить в настройках аккаунта. После успешной аутентификации пользователь будет перенаправлен на страницу с фаззерами.

## Рабочие вкладки

В веб-интерфейсе BondiFuzz есть следующие вкладки:

**Projects** — созданные пользователем проекты и проект `default`, который создается по-умолчанию при создании пользователя.

**Fuzzers** — созданные пользователем фаззеры. Пользователь загружает фаззинг-тесты, может запускать и останавливать их, добавлять новые версии, удалять.

**FAQ** — часто задаваемые вопросы.

**Documentation** — документация по работе с BondiFuzz.

**Trash** — корзина, куда перемещаются удаленные фаззинг-тесты.

Во вкладке **Fuzzers** есть следующие вкладки:

**Versions** — после каждого внесения изменения в фаззинг-тест пользователь может создавать новую версию, затем можно сравнить работу разных версий одного фаззинг-теста, а также эта возможность поможет вернуться к предыдущей версии, если изменения оказались неудачными.

**Crashes** — крэши, обнаруженные фаззинг-тестами, с возможностью сортировки по версии.

**Statistics** — статистика, собираемая на основе работы фаззинг-тестов. Показывает метрики фаззинг-тестов, по которым оценивается эффективность их работы. Есть возможность выбора версии фаззинг-теста и временного промежутка, за который необходима статистика.

Для фаззинга понадобятся следующие файлы:

**Binaries** — бинарный файл фаззинг-теста. 

**Seeds** — директория с файлами, содержимое которых должно быть валидным с точки зрения целевой программы или функции. Сиды будут подвергаться многочисленным мутациям в процессе фаззинга и приводить к росту покрытия кода. В процессе фаззинга сиды трансформируются в корпус. Корпус (corpus) — это набор тест-кейсов, которые привели к росту покрытия кода во время фаззинга целевой программы или функции. В корпусе сначала содержатся сиды, потом — их мутации, затем — мутации мутаций и т.д.

**Options and environment** — дополнительные опции.

**Image** — докер-образ агента. Агент — это программа, которая запускается первой при запуске контейнера и запускает сам фаззинг-тест. Агент собирает результаты фаззинга и статистику. На данный момент этот файл загружается администраторами BondiFuzz.