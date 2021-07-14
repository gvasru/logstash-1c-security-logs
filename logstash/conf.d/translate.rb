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
    event.set('messagesource',event.get('message'))
       
  event.set('Date',event.get('parsedData')[0])
  event.set('StatusTransaction',event.get('parsedData')[1])
  event.set('Transaction',event.get('parsedData')[2])
  event.set('UserInnerId',event.get('parsedData')[3])
  event.set('computerInnerId',event.get('parsedData')[4])
  event.set('NameApplicationId',event.get('parsedData')[5])
  event.set('Connection',event.get('parsedData')[6])
  event.set('EventId',event.get('parsedData')[7])
  event.set('Importance',event.get('parsedData')[8])
  event.set('Comment',event.get('parsedData')[9])
  
  @MetadataId=event.get('parsedData')[10]

  event.set('MetadataId',@MetadataId) 

   
 @objectdata=event.get('parsedData')[11]  #Данные


  event.set('datadescr',event.get('parsedData')[12])  #Представление данных
  begin
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
        event.set('data',@objectdata)
      else 
        event.set('data',@objectdata)
      end
    end
  rescue  Exception => e  
    event.set('ParseDataException',e.message ) 
  end
  event.set('MainIpPortid',event.get('parsedData')[14])
  event.set('SecondIpPort',event.get('parsedData')[15])
  event.set('Session',event.get('parsedData')[16])
  #event.set('WorkServerId',event.get('parsedData')[18]) 
  event.set('message','')   
  	return [event]
  rescue  Exception => e  
    event.set('translateException',e.message ) 
  end
  
end
