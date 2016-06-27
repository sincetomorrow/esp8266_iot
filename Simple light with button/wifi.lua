print("No enduser, wifi setup")
dofile("config.lua")

wifi.setmode(wifi.STATIONAP);
wifi.sta.config("ping","annapanos")
cfg = { ip=IP, netmask="255.255.255.0", gateway="192.168.1.1" }

wifi.sta.setip(cfg)
wifi.sta.connect()