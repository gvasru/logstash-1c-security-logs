# the value of `params` is the value of the hash passed to `script_params`
# in the logstash configuration

$messagetoparseField="NODATA"

def register(params)
	$messagetoparseField = params["messagefield"]
end

# the filter method receives an event and must return a list of events.
# Dropping an event means not including it in the return array,
# while creating new ones only requires you to add a new instance of
# LogStash::Event to the returned array
def filter(event)
    @message=event.get($messagetoparseField)
    #begin
      parselog(@message,event)
    #rescue  Exception => e  
    #  event.tag("parseException")
    #  event.set('parseException',e.message ) 
    #  puts "parse error "+e.message+" string "+ @message
    #  throw e
    #end
   
  	return [event]
end
# В случае ошибки парсинга - создавать событие
#def parseErrorEvent(source,position,stringmode) 
#  new_custom_event = LogStash::Event.new()
#  new_custom_event.set("cpu_test_load", 34)
#  new_event_block.call(new_custom_event)
#end

def parselog(message,event)
    message.gsub! "\r\n","{r5n}"
    message.gsub! "\r","{r5r}"
    message.gsub! "\n","{n5n}"


    m=message.scan(/^\d{2}:\d{2}.\d{6}-\d{1,},\w{2,10},\d{1,},/)
    if (!m.nil? and m.size>0)
        header=m[0]
        message.gsub! header,""
        #event.set('header',header)    
    end
    a= message.index(",")
    while !a.nil? do
        e=message.index("='")
        if !e.nil? and a>e 
            #puts "e=#{e} a=#{a}"
            name=message[0,e]
            t=message.index("',")
            if true or message[e+1,message.size].reverse[0,1]="'"
                val=message[e+1,message.size]
                val.gsub! "{n5n}","\n"
                val.gsub! "{r5r}","\r"
                val.gsub! "{r5n}","\r\n"
            end
            #puts "name=#{name} val=#{val}"
            event.set(name,val)  
            break	
        end
        e=message.index("=\"")
        if !e.nil? and a>e 
            #puts "e=#{e} a=#{a}"
            name=message[0,e]
            t=message.index("',")
            if true or message[e+1,message.size].reverse[0,1]="'"
                val=message[e+1,message.size]
                val.gsub! "{n5n}","\n"
                val.gsub! "{r5r}","\r"
                val.gsub! "{r5n}","\r\n"
            end
            #puts "name=#{name} val=#{val}"
            event.set(name,val)  
            break	
        end

        x=message[0,a]
        aname= x.scan (/.{2,}(?==)/)
        aval= x.scan (/(?<==).*/)
        val=aval[0]
        name=aname[0]
		if val.nil? 
			puts x
		end
        val.gsub! "{n5n}","\n"
        val.gsub! "{r5r}","\r"
        val.gsub! "{r5n}","\r\n"
        event.set(name,val)  
        #puts "name=#{name} val=#{val}"
        message= message[a+1,message.size]
        a= message.index(",")
    end
end