# Экспорт журнала регистрации 1с в elasticsearch средствами logstash
Это решение помогает настроить импорт журнала регистрации 1с в logstash и экспорт в elasticsearch.
## Журнал регистрации 1с 
Решение для "старого" формата журнала регистрации (не SQLite). 
Желательно разделить файлы журнала регистрации по дням (для вашего же удобства)
## Хранение журнала регистрации
Файлы журнала регистрации 1с находятся на сервере 1с в папке srvinfo\reg_1541\\<идентификатор базы>\1Cv8Log
И состоят из 2 частей:
*.lgp - журнал регистрации
1Cv8.lgd - словарь данных

# Установка elasticsearck,logstash,kibana
https://www.elastic.co/downloads/logstash
* Тестировалось на logstash-7.13.2-windows-x86_64

* (опционально)Установка logstash как службы windows
https://www.elastic.co/guide/en/logstash/current/running-logstash-windows.html

## Определить в какой папке хранится ЖР для базы:
Открыв файл srvinfo\reg_1541\1CV8Clst.lst блокнотом - вы увидите имя базы на сервере и ее идентификатор (= папка, куда складываются логи) 

> Все нижеописанные действия поможет сформировать обработка ПомошникЭкспортаЖурналаРегистрации1с. 
> Запустить можно в любой (даже пустой) базе.

## Экспорт справочников
Перед экспортом журнала регистрации нужно создать словари для данных из файла 1Cv8.lgd. 
Используется скрипт:

```lgf-to-yml.ps1 ""C:\Program Files\1cv8\srvinfo\reg_1541\<Идентификатор базы>\1Cv8Log\1Cv8.lgd""  ""Имя БД"" ""<ПапкаУстановкиlogstash>\mappings""```

В Результате выполнения скрипта в каталоге <ПапкаУстановкиlogstash>\mappings должны появиться файлы 
> <Имя БД>_UserId.yml
> <Имя БД>UserDescr.yml
> и т.д.

Т.к. в журнале регистрации иногда появляются новые данные требуется обеспечить периодическое обновление этих данных с помощью, допустим TaskSheduler:

```powershell -Command "$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument '-File """<ПапкаLOGSTASH>\lgf-to-yml.ps1"" """C:\Program Files\1cv8\srvinfo\reg_1541\<ИДБазы>\1Cv8Log\1cv8.lgf""" ""<ИмяБазы>"" ""<ПапкаLOGSTASH>\mappings""' ; $trigger =  New-ScheduledTaskTrigger -Daily -At 9am ; Register-ScheduledTask -Action $action -Trigger $trigger -TaskName 'Logshash export dictionary <ИмяБазы>' -Description 'Экспорт словарей данных для БД rp30 (<ИДБазы>) в папку <ПапкаLOGSTASH>'"```

Скрипт lgf-to-yml.sh из "оригинальной" версии не тестировался и,наверное, не работает. Буду благодарен если кто-то доработает.

## Создание pipeline для базы данных:

Скопируйте в папку logstash\config файл conf.d\example1c.conf и переименуйте его в <ИмяБазы>.conf
В файле конфига <ИмяБазы>.conf заполните:
Путь к файлам ЖР
> path => ["C:\Program Files\1cv8\srvinfo\reg_1541\<идентификатор базы>\1Cv8Log\*.lgp"]
> type => "имяБД"

Замените в каждой строчке
> dictionary_path => "mappings/{ИмяБазы}_WorkServerPorts.yml" 

##  Скопируйте файлы 
> conf.d/parse.rb => <ПапкаУстановкиlogstash>/config/parse.rb
> conf.d/translate.rb => <ПапкаУстановкиlogstash>/config/translate.rb
> mapping/1Cv8Log.json => <ПапкаУстановкиlogstash>/mapping/1Cv8Log.json

# Проверка
В Файле <ИмяБазы>.conf закомментируйте/удалите отправку данных в elasticsearch

Запустите logstash 
``` logstash -c <ИмяБазы>.conf```

В консоле появится результат.   

# Формат файлов
## lgp:
0) Дата и время в формате "yyyyMMddHHmmss"
1) Статус транзакции – может принимать четыре значения "N" – "Отсутствует", "U" – "Зафиксирована", "R" – "Не завершена" и "C" – "Отменена";
2) Транзакция в формате записи из двух элементов преобразованных в шестнадцатеричное число – первый – число секунд с 01.01.0001 00:00:00 умноженное на 10000, второй – номер транзакции;
3) Пользователь – указывается номер в массиве пользователей (парсится из справочников - файлы DB_NAME_UserId и DB_NAME_UserDescr)
4) Компьютер – указывается номер в массиве компьютеров (парсится из справочников - файл DB_NAME_ComputerId)
5) Приложение – указывается номер в массиве приложений (парсится из справочников - файл DB_NAME_Applications)
6) Соединение – номер соединения (парсится из справочников - файл DB_NAME_Applications)
7) Событие – указывается номер в массиве событий (парсится из справочников - файл DB_NAME_EventId)
8) Важность – может принимать четыре значения – "I" – "Информация", "E" – "Ошибки","W" – "Предупреждения" и "N" – "Примечания";
9) Комментарий – любой текст в кавычках;
10) Метаданные – указывается номер в массиве метаданных (парсится из справочников - файл DB_NAME_MetadataId)
11) 
12) Данные – самый хитрый элемент, содержащий вложенную запись. (TODO Заполнить расшифровку)
13) Представление данных;
14) ? Код 13 в lgf-файле - это аналог записи таблицы ComputerToUserCodes в журнале lgd. Где в нулевом элементе массива код вида элемента, в 1м - код компьютера, а во 2м - код пользователя. 
15) ?
16) ?
17) ?
18) Сервер – указывается номер в массиве серверов (парсится из справочников - файл DB_NAME_WorkServerId)
19) ?
20) ?
21) ?

## 1Cv8.lgd:
1) – пользователи;
2) – компьютеры;
3) – приложения;
4) – события;
5) – метаданные;
6) – серверы;
7) – основные порты;
8) – вспомогательные порты.
Так же встречаются пока неопознанные коды 11, 12 и 13

# Оригинальное описание
https://xdd.silverbulleters.org/t/bigdata-logmanager-dlya-1s/62/140

https://xdd.silverbulleters.org/t/bigdata-logmanager-dlya-1s/62/143

# Ссылки 
Описание формата лога 1с почерпнуто из статей

https://infostart.ru/1c/articles/182061/

https://infostart.ru/public/182820/

По ссылкам похоже что "старая" версия формата логов. Описание некоторых полей я не нашел.
