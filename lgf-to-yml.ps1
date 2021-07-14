#Скрипт для создания словарей базы данных

# Параметры запуска сценария: <Путь к файлу lgf> <Имя БД> <Путь для сохранения>




$LgfPath=$args[0]

if (!$LgfPath){
  write-host "Не указан Путь к файлу lgf." -foregroundcolor red
  write-host "Пример параметров ""C:\Program Files\1cv8\srvinfo\reg_1541\<Идентификатор базы>\1Cv8Log\1Cv8.lgd""  ""Имя БД"" ""<ПапкаЭкспорта>""]"
  exit -1
}

$dbname=$args[1]

if (!$dbname){
  write-host "Не указано Имя БД" -foregroundcolor red
  write-host "Пример параметров ""C:\Program Files\1cv8\srvinfo\reg_1541\<Идентификатор базы>\1Cv8Log\1Cv8.lgd""  ""Имя БД"" ""<ПапкаЭкспорта>""]"
  exit -1
}
$savepath=$args[2]
if (!$savepath){
  write-host "Не указан Путь для сохранения" -foregroundcolor red
  write-host "Пример параметров ""C:\Program Files\1cv8\srvinfo\reg_1541\<Идентификатор базы>\1Cv8Log\1Cv8.lgd""  ""Имя БД"" ""<ПапкаЭкспорта>""]"
  exit -1
}
  

function Install-1cv8YMLData($hashtable,$filepath) {
    Remove-Item $filepath  -Force -Confirm:$false
    foreach ($key in $hashtable.Keys)
    {
        $string=""""+$key+""": "+$hashtable[$key]
        Add-Content $filepath $string -encoding UTF8
    }
    Add-Content $filepath  """ "":"  -encoding UTF8
    Add-Content $filepath  """0"":"  -encoding UTF8
    Add-Content $filepath  """"":"  -encoding UTF8
}

$hashtableUserid = @{}
$hashtableUserdescr = @{}
$hashtableComputers = @{}
$hashtableApplications = @{}
$hashtableEvents = @{}
$hashtablemetadescr = @{}
$hashtablemeta = @{}
$hashtableservers = @{}
$hashtableserverports = @{}


$header="";
$dbid="";
$lineno=0;
$addon=""

foreach($line in Get-Content $LgfPath) {
    $lineno=$lineno+1

    if ($lineno -eq 1){
        if ($line="1CV8LOG(ver 2.0)"){
            $header=$line
            continue;
        }
        else{
            break
        }
    } 
    elseif ($lineno -gt 3) {
        if ($addon -ne ""){
            $line=$addon + $line
            #write-host $line
        } 
        if ($line.Split('{').Length -ne $line.Split('}').Length){
            $addon=$line
            continue;
        }
        else{
            write-host  $line
                $addon=""
        }
        $line2= $line  -replace '{',''  -replace '},','' 

        $xxx=$addon + $line2
        # последний элемент
        if ($xxx.Substring($xxx.Length-1,1) -eq '}'){
                $xxx=$xxx.Substring(0,$xxx.Length-1)
        }

        $arr=$xxx.Split(',')
        # 1 – пользователи;
        # 2 – компьютеры;
        # 3 – приложения;
        # 4 – события;
        # 5 – метаданные;
        # 6 – серверы;
        # 7 – основные порты;
        # 8 – вспомогательные порты.
        # Так же встречаются пока неопознанные коды 11, 12 и 13
        if ($arr[0] -eq 1){
            $hashtableUserdescr[$arr[3]]=$arr[2]
            $hashtableUserid[$arr[3]]=$arr[1]
        }
        elseif ($arr[0] -eq 2) {
            $hashtableComputers[$arr[2]]=$arr[1]
        }
        elseif ($arr[0] -eq 3) {
            $hashtableApplications[$arr[2]]=$arr[1]
        }
        elseif ($arr[0] -eq 4) {
            $hashtableEvents[$arr[2]]=$arr[1]
        }
        elseif ($arr[0] -eq 5) {
            $hashtablemetadescr[$arr[3]]=$arr[2]
            $hashtablemeta[$arr[3]]=$arr[1]
        }
        elseif ($arr[0] -eq 6) {
            $hashtableservers[$arr[2]]=$arr[1]
        }
        #Основной порт сервера
        elseif ($arr[0] -eq 7) { 
            $hashtableserverports[$arr[2]]=$arr[1]
        }
    }        
}



$filepath=$savepath+"\"+$dbname+"_UserDescr.yml"


Install-1cv8YMLData -hashtable $hashtableUserdescr -filepath $filepath  

$filepath=$savepath+"\"+$dbname+"_UserId.yml"
Install-1cv8YMLData -hashtable $hashtableUserid -filepath $filepath  

$filepath=$savepath+"\"+$dbname+"_EventId.yml"
Install-1cv8YMLData -hashtable $hashtableEvents -filepath $filepath 

$filepath=$savepath+"\"+$dbname+"_Applications.yml"
Install-1cv8YMLData -hashtable $hashtableApplications -filepath $filepath  

$filepath=$savepath+"\"+$dbname+"_ComputerId.yml"
Install-1cv8YMLData -hashtable $hashtableComputers -filepath $filepath  

$filepath=$savepath+"\"+$dbname+"_MetadataId.yml"
Install-1cv8YMLData -hashtable $hashtablemeta -filepath $filepath  

$filepath=$savepath+"\"+$dbname+"_MetadataDescr.yml"
Install-1cv8YMLData -hashtable $hashtablemetadescr -filepath $filepath  

$filepath=$savepath+"\"+$dbname+"_EventId.yml"
Install-1cv8YMLData -hashtable $hashtableEvents -filepath $filepath  

$filepath=$savepath+"\"+$dbname+"_WorkServerId.yml"
Install-1cv8YMLData -hashtable $hashtableservers -filepath $filepath  

$filepath=$savepath+"\"+$dbname+"_WorkServerPorts.yml"
Install-1cv8YMLData -hashtable $hashtableserverports -filepath $filepath  
