-- A simple http client posting data with get in thingspeak
print("Thingspeak function loaded")
key = "ZJV61FDJO1LCDZIG";

function postThingspeak(value) 
    connout = nil
    connout=net.createConnection(net.TCP, 0)
    
    connout:on("receive", function(connout, payload)
        if (string.find(payload, "Status: 200 OK") ~= nil) then print("Posted OK > "..state); end
    end)
    connout:on("connection",function(connout,payload)
        connout:send("GET /update?api_key="..key.."&field1="..value.."&field2"..node.chipid()
    .." HTTP/1.1\r\nHost: api.thingspeak.com\r\nConnection: keep-alive\r\nAccept: */*\r\n\r\n")
    end)
    connout:on("disconnection",function(connout,payload) connout:close(); collectgarbage(); end)
    
    connout:connect(80,"api.thingspeak.com")
end
