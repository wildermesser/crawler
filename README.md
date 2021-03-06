# crawler
Проект по созданию конвейера разработки, мониторинга и разворачивания приложения _search engine crawler_ `https://github.com/wildermesser/search_engine_crawler` и инетфейса к нему `https://github.com/wildermesser/search_engine_ui`
## Общее описание
### IaaC
Все исользуемые сервисы разворачиваются в Docker контейнерах. Подготовка инфраструктуры осуществляется с помощью terraform.
### CI/CD
Для CI/CD используется Jenkins.
### Мониториг, логирование
Для сбора метрик используется Telegraf. Метрики отправляются в Influxdb. Для визуализации используется Chronograf. Для алертинга испльзуется Kapacitor. Для логгирования используется стек ElasticSearch+Filebeat+Kibana.
## Инфраструктура
В директории terraform хранится описание статических виртуальных машин для Jenkins, TICK-стека, EFK-стека  и production приложения crawler. Виртуальные машины для тестирования кода из веток создаются динамически.

Так как все сервисы запускаются в Docker, основным требования для виртуальных машин является рабочий Docker daemon. Для экономии времени при создании нового инстанса, а также для закрепления используемых версий создан шаблон `packer`, который на основе Ubuntu 18.04 создаёт образ с установленным Docker. Шаблон описан в директории `packer`.

Также из этого требования следует, что на низком уровне машины будут отличаться только аппаратными ресурсами и скриптом инициализации, который в  общем случае представляет копирование файла `docker-compose.yml` и его запуска. Поэтому  в репозитории https://github.com/wildermesser/dockerinstance находится описание модуля `dockerinstance`

Для удобства обращения к созданным хостам создан домен `ocrawler.tk`. Создаваемые машины будут иметь свои имена в этом домене благодаря настройке Goole Cloud DNS с помощью terraform. Списко хостов:
 - jenkins.ocrawler.tk: сервер Jenkins
 - monitoring.ocrawler.tk: сервер с TICK
 - logging.ocrawler.tk: сервер с ElasticSearch и Kibana
 - production.ocrawler.tk: сервер с search_engine_crawler и search_engine_ui

## CI/CD
Jenkins сервер запущен в docker контейнере и он должен собирать контейнеры приложений. Существует несколько способов предоставить Jenkins доступ к docker демону. В данном проекте выбран способ запуска контейнера Jenkins с параметром `-u root`. Благодаря такому способу нет необходимости использовать Docker-in-Docker и кэширование образов будет работать для все собираемых контейнеров. Это не идеальный спобов в плане безопасности, но для данного проекта это не критично.

Репозитории `crawler` и `ui` находятся на `github.com`. Каждый содержит `Dockerfile` для сборки контейнера. Также каждый репозиторий содержит `Jenkinsfile` с описанием конвейера сборки.

Сервер: http://jenkins.ocrawler.tk:8080/

Сборка: оба приложения собираются в образ, описанный в `Dockerfile` и помечаются тегом текущей ветки
Тестирование: оба приложения собираются в обаз для тестирования на основе `Dockerfile-test`. Затем запускается команда тестирования.
Разработка в ветке, отличной от master: собранные образы запускаются на временном инстансе с помощью docker-compose на основе `Docker-compose.yml` файла. Версии из образов берутся из переменных окружения
При коммите в master и успешной сборке и тестировании образов на инстансе `production.ocrawler.tk` запускается приложения с обновлёнными версиями образов. Запуск происходит только после нажатия кнопки подтверждения и только для пользователя `admin`.

## Мониторинг
Мониторинг выполнен на базе TICK стека, основное взаимодействие осуществляется через интерфейс Chronograf, расположенный по адресу http://monitoring.ocrawler.tk

Созданы 2 dashboard, отражающие состояние production как сервера и как приложения crawler. Также присутствуют автоматически создаваемые графики на основе собранных метрик. Оба dashboard выгружены в директорию `dashboards`.

Создано 4 правила уведомления, которые представлены в виде TICK скриптов в директории `alerts`.
  - Отсутствие ответа от сервиса crawler в течение заданного интервала
  - Загрузка процессора более 20%
  - Ответ сервиса UI, отличный от 200
  - Превышение ответа сервиса UI более 5 секунд

Метрики собираются с помощью Telegraf и встроенных в него плагинов. Конфигурация хранится в файле `telegraf.conf`. Причём используется два экземпляра этого сервиса. Один на production собирает метрики системы, docker контейнеров и приложения, а другой на самом monitoring для сбора метрик самой системы мониторинга, а так же для опроса UI сервиса извне.

## Логирование
Сервис логирования доступен по адресу http://logging.ocrawler.tk. Здесь запущен ElasticSearch и Kibana. А сбор логов с контейнеров на production огранизован с помощью Filebeat. Конфигурация Filebeat задана в файле `filebeat.yml`.
