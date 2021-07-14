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

    @message=event.get('message')

    begin
      @parsedData=parselog(@message,1,false)
    rescue  Exception => e  
      event.set('parselogException',e.message ) 
      throw e
    end
    event.set('parsedData',@parsedData["data"])    
  	return [event]
end

def parselog(message,position,stringmode) 
  dataToReturn = {}
  dataToReturn.store("start", position)
  arrchars=message.chars()
  thisobj=Array.new(0)
  arritem=0
  startdata=position
  start=position
        while arrchars.length-1>=position do
            if stringmode == true then
              if  arrchars[position] == '"' and arrchars[position+1] != '"'
                stringmode=false
                 dataToReturn.store("end", position)
                 dataToReturn.store("string", message[start,position-start])
                 dataToReturn.store("data", message[start,position-start])
                return  dataToReturn
              elsif arrchars[position] == '"' and arrchars[position+1] == '"'
                position=position+2 
                next
              end
            elsif arrchars[position] == '{' then
              position+= 1
              obj=parselog(message,position,false) 
              position=obj["end"]+1  
              thisobj[arritem]=obj["data"]
              arritem+=1 
              startdata=position
              next
            elsif arrchars[position] == ','
              if position!=startdata 
                 arritem+=1
              end
              startdata=position+1 
            elsif arrchars[position] == '"' then
              if arrchars[position+1] == '"' then
                #Если это пустая строка
                thisobj[arritem]=""
                position=position+2 
                next
              else
                obj=parselog(message,position+1,true)  
                position=obj["end"]+1
                thisobj[arritem]=obj["data"]
                arritem+=1
              end  
              if arrchars[position]=='}' then
                dataToReturn.store("string", message[start,position-start])
                position=position
                dataToReturn.store("end", position)
                dataToReturn.store("data", thisobj)
                return  dataToReturn
              elsif arrchars[position]==',' then
                startdata=position+1
                position=position+1
                next
              end              
            elsif arrchars[position] == '}'
             if position!=startdata  
                thisobj[arritem]=message[startdata,position-startdata]
             end
              dataToReturn.store("end", position)
              dataToReturn.store("string", message[start,position-start])
              dataToReturn.store("data", thisobj)
              return  dataToReturn
            end
            position=position+1 
        end

    position=position+1 
    dataToReturn.store("end", position)
    dataToReturn.store("string", message[start,position-start])
    dataToReturn.store("data", thisobj)
   return  dataToReturn  
end