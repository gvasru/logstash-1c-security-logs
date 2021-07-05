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
# event.set('raw_log_file',event.get('path').split('/')[-1].gsub('.lgp','').slice(0..7))


    @message=event.get('message')
 
    @parsedData=parselog(@message,1,false)

    event.set('parsedData',@parsedData["data"])    
	return [event]

end

def parselog(message,position,stringmode)
    hhh = {}
    hhh.store("start", position)
    arrchars=message.chars()
    thisobj=Array.new(0)
    arritem=0
    startdata=position
    start=position
  
          while arrchars.length>=position-1 do
              if stringmode == true then
                 if arrchars[position] == '"'
                   stringmode=false
                   hhh.store("end", position)
                   hhh.store("string", message[start,position-start])
                   hhh.store("data", message[start,position-start])
                   return  hhh
                end
              elsif arrchars[position] == '{' then
                position+= 1
                obj=parselog(message,position,false)               
                position=obj["end"]+1              
                thisobj[arritem]=obj["data"]
                startdata=position+1
                arritem+=1
              elsif arrchars[position] == ','
                thisobj[arritem]=message[startdata,position-startdata]
                startdata=position+1
                arritem+=1
              elsif arrchars[position] == '"'
                obj=parselog(message,position+1,true)
  
                position=obj["end"]
                thisobj[arritem]=obj["data"]
                arritem+=1
                startdata=position
                ccc=arrchars[(position+1)]
                if ccc=='}'
                  hhh.store("string", message[start,position-start])
                  position=position+1
                   hhh.store("end", position)
                   hhh.store("data", thisobj)
                    return  hhh
                end
  
                
              elsif arrchars[position] == '}'
               thisobj[arritem]=message[startdata,position-startdata]
                hhh.store("end", position)
                hhh.store("string", message[start,position-start])
                hhh.store("data", thisobj)
                return  hhh
              end
              position=position+1 
          end
  
      position=position+1 
      hhh.store("end", position)
      hhh.store("string", message[start,position-start])
      hhh.store("data", thisobj)
     return  hhh  
  end
  

  