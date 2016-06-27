print("Enduser module loaded")

enduser = 1
cfg = { ip=IP, netmask="255.255.255.0", gateway="192.168.1.1" }

wifi.setmode(wifi.STATIONAP)
wifi.sta.setip(cfg)
wifi.ap.config({ssid="ESP_"..node.chipid(),auth=wifi.AUTH_OPEN})
enduser_setup.manual(true)
enduser_setup.start(
  function()
    print("Connected to wifi as:" .. wifi.sta.getip())
    enduser_setup.stop();
    dofile("simple"..device_type..".lua");
  end,
  function(err, str)
    print("enduser_setup: Err #" .. err .. ": " .. str)
  end
);
