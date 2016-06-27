nodemcu = "15" -- or 9
enduser = 1 -- NodeMCU >1.5 supports enduser_setup
IP = "192.168.1.104"
device_type = "light"

if(enduser==0) then dofile("simple"..device_type.."plug.lua") 
elseif(enduser==1) then dofile("enduser.lua")
end