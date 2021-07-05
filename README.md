# Пример настроек для logstash для импорта логов 1с в формате lgf
Описание формата лога 1с: 
https://infostart.ru/1c/articles/182061/
https://infostart.ru/public/182820/

# Настройка
Файлы логов 1с находятся в папке srvinfo\reg_1541\<идентификатор базы> 
Какой идентификатор принадлежит какой базе можно посмотреть в файле 1CV8Clst.lst
В файле конфига logstash заполните:

path => ["srvinfo\reg_1541\<идентификатор базы>\*.lgp"]
start_position => "beginning"
type => "имяБД"
    
# Справочники
Файлы журнала регистрации 1с делятся на 2 части: сам журнал регистрации и "словать" данных. 
Поэтому перед экспортом журнала регистрации нужно создать словари для этих данных. 

Для этого используются скрипты lgf-to-yml.ps1 или lgf-to-yml.sh
Перед запуском измените путь к файлам в зависимости от идентификатора базы:
conf.d/custom_mapping_1C/DB_NAME_UserId.yml



# Форк. Оригинальное описание
https://xdd.silverbulleters.org/t/bigdata-logmanager-dlya-1s/62/140

https://xdd.silverbulleters.org/t/bigdata-logmanager-dlya-1s/62/143
