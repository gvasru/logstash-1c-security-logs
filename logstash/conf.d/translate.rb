# the value of `params` is the value of the hash passed to `script_params`
# in the logstash configuration
def register(params)
	@messagefield = params["messagefield"]
end

# the filter method receives an event and must return a list of events.
# Dropping an event means not including it in the return array,
# while creating new ones only requires you to add a new instance of
# LogStash::Event to the returned array
def filter(event)


  begin
    parsedData=event.get('parsedData')
    event.set('messagesource',event.get('message'))    
    event.set('Date',parsedData[0])
    event.set('StatusTransaction',parsedData[1])
    event.set('Transaction',parsedData[2])
    event.set('UserInnerId',parsedData[3])
    event.set('computerInnerId',parsedData[4])
    event.set('NameApplicationId',parsedData[5])
    event.set('Connection',parsedData[6])
    event.set('EventId',parsedData[7])
    event.set('Importance',parsedData[8])
    event.set('Comment',parsedData[9])

    @MetadataId=parsedData[10]
    event.set('MetadataId',@MetadataId) 
    @objectdata=parsedData[11]  #Данные

    event.set('datadescr',parsedData[12])  #Представление данных
    begin
      translateDataObject(event,parsedData)
    rescue  Exception => e  
      event.set('translateDataObjectException',e.message ) 
      event.tag("translateDException")
    end
    event.set('MainIpPortid',parsedData[14])
    event.set('SecondIpPort',parsedData[15])
    event.set('Session',parsedData[16])
    #event.set('WorkServerId',parsedData[18]) 
    event.set('message','')   
  	return [event]
  rescue  Exception => e  
    event.set('translateException',e.message ) 
  end
  
end


##################################################
# Функция преобразования объекта из события ЖР
def translateDataObject(event,parsedData)
  if @objectdata.respond_to?('each') then
    if @objectdata.length==1  then
      event.set('datatype','')
      event.set('data','')
    elsif @objectdata[0]=='S' then
            event.set('datatype',@objectdata[0])
            event.set('data',@objectdata[1])
            event.set('datadescr',@objectdata[1])
    elsif @objectdata[0]=='N' then
            event.set('datatype',@objectdata[0])
            event.set('data',@objectdata[1])
    elsif @objectdata[0]=='R' then
          event.set('datatype',@objectdata[0])
          #event.set('datatypeid',@objectdata[1])
          event.set('data',@objectdata[1])
    elsif @objectdata[0]=='P' then
      event.set('datatype',@objectdata[0])
      # Для события "_$Session$_.Authentication" возвращается:
      # "data" => [
      # [0] "P",
      # [1] [
      #     [0] "6",
      #     [1] [
      #         [0] "S",
      #         [1] "Администратор"
      #     ],
      #     [2] [
      #         [0] "S",
      #         [1] "RUSPETROL\\svc_1c_agent"
      #     ]
      # ]
      event.set('data',@objectdata[1])
    else 
      event.set('data',@objectdata)
    end
  end
end