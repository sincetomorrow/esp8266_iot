print("Simple plug loaded");

plug = 4 --GPIO 02
button = 3 -- GPIO 00
state = 0

gpio.mode(plug, gpio.OUTPUT);
gpio.write(plug, gpio.LOW);

gpio.mode(button,gpio.INT,gpio.PULLUP)

local lampColor = ""
local onclass = "";
local offclass = "";
local debounceDelay = 200
local debounceAlarmId = 0;

function buttonClicked()
    if(state==0)then state = 1; gpio.write(plug, gpio.HIGH);
    elseif(state==1)then state = 0; gpio.write(plug, gpio.LOW);
    end
    gpio.trig(button, "none")
    tmr.alarm(debounceAlarmId, debounceDelay, tmr.ALARM_SINGLE, function()
        gpio.trig(button, "down", buttonClicked)
    end)
end

gpio.trig(button, "down", buttonClicked)

if(enduser==0) then dofile("wifi.lua") end

print(wifi.sta.getip())
srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive", function(conn,request)
        local buf = "";
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end
        local _GET = {}
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
            end
        end
        local _on,_off = "",""
        if(_GET.PIN == "ON1")then
              pwm.close(plug); gpio.write(plug, gpio.HIGH); state=1; onstate=""; offstate="off"; lampColor = "#D6D245";
        elseif(_GET.PIN == "OFF1")then
              gpio.write(plug, gpio.LOW); pwm.close(plug); state=0; onstate="off"; offstate=""; lampColor = "#333333";       
        elseif(_GET.PIN == "ON")then
              pwm.setup(plug,1000,128); state=1; onstate=""; offstate="off"; lampColor = "#717220";
              pwm.start(plug)
        elseif(_GET.PIN == "OFF2")then
            pwm.close(plug); state=0; onstate="off"; offstate=""; lampColor = "#333333";
        elseif(gpio.read(plug)==1) then
            onstate=""; offstate="off"; lampColor = "#D6D245";
        elseif(gpio.read(plug)==0) then
            state=0; onstate="off"; offstate=""; lampColor = "#333333";
        end
        
        buf = buf.."<div class='container-fluid'><div class='row'>"
        buf = buf.."<div class='col-md-12 text-center'>"
        buf = buf.."<h1>The force is strong in this house.</h1><h4>"..node.chipid().." / "..wifi.sta.getip().."</h4>"
        buf = buf.."<a href='?PIN=ON'><span class='glyphicon glyphicon-sunglasses fa-4x' aria-hidden='true' style='color:"..lampColor.."'></span></a>";
        buf = buf.."<p>LED </p> <a href='?PIN=ON1'><button class='"..onstate.."'>ON</button></a> ";
        buf = buf.."<a href='?PIN=OFF1'><button class='"..offstate.."'>OFF</button></a>";
        buf = buf.."</div>" 
        buf = buf.."</div></div>";

        if(_GET.PIN == "read") then
            conn:send(gpio.read(plug));
            conn:close();
        else  
            headers = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nConnection: close\r\n\r\n"
            headers=headers..'<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"/>'
            headers=headers..'<meta name="viewport" content="width=device-width, initial-scale=1">'
            headers=headers..'<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css">'
            headers=headers..'<title>Hello home ('..node.chipid()..')!</title></head><body bgcolor="black">'
            headers=headers..'<style>'
            headers=headers..'.fa-4x{font-size:100px;color:#D6D245;}'
            headers=headers..'h1{color:white;}h2,h3,h4{color:grey;}body,html{color:white;background:black;}'
            headers=headers..'button{background:white;border:1px solid white;color:black;padding:10px 14px;font-size:20px;border:none;font-weight:500;}'
            headers=headers..'.off{background:none;color:white;font-weight:200;border:1px solid #999999;}'
            headers=headers..'</style></head><body>'
            buf = headers..buf.."</body></html>"
            conn:send(buf)
            collectgarbage()
        end
    end)
    conn:on("sent", function(conn) conn:close() end)
end)