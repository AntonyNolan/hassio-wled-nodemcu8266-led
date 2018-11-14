--SAFETRIM

local mod

local function start()
  if PDEBUG then
    dofile("websocket.lc")
  else
    dofile("websocket.lc")
  end

  local responseTimer = tmr.create()
  responseTimer:register(60, tmr.ALARM_SEMI, function()
    local state = sjson.encode(mod.getStatus())
    print("Sending", state)
    websocket.send(state) -- update State to all websocket clients
  end)

  websocket.createServer(80, function (socket)
    -- This gets executed once a websocket client connects, once per client
    -- websocket ping function resets softwd every 5 minutes
    tmr.softwd(600)
    local data
    --  node.output(function (msg)
    --    return socket.send(msg, 1)
    --  end, 1)
    print("New websocket client connected")

    function socket.onmessage(payload, opcode)
      print("received", payload, opcode)
      local s, cmd; s, cmd = pcall(sjson.decode, payload)
      if type(cmd) == 'table' then
        --print("decoded", sjson.encode(cmd))
        print("Command", cmd["cmd"], cmd["func"])
        if cmd["cmd"] == "set" then
          if cmd["func"] == "on" then
            mod.setOn(cmd["value"])
          elseif cmd["func"] == "brightness" then
            mod.setBrightness(cmd["value"])
          elseif cmd["func"] == "hue" then
            mod.setHue(cmd["value"])
          elseif cmd["func"] == "saturation" then
            mod.setSaturation(cmd["value"])
          elseif cmd["func"] == "ct" then
            mod.setCT(cmd["value"])
          else
            print("Unknown function", cmd["func"])
          end
          responseTimer:start()
        elseif cmd["cmd"] == "get" then
          if cmd["func"] == "id" then
            local majorVer, minorVer, devVer, chipid, flashid, flashsize, flashmode, flashspeed = node.info()
            local response =
            "{ \"Hostname\": \""..config.ID.."\", \"Model\": \""..config.Model.."\", \"Version\": \""..config.Version.."\", \"Firmware\": \""..majorVer.."."..minorVer.."."..devVer.."\" }"
            print("Sending", response)
            socket.send(response)
          elseif cmd["func"] == "status" then
            local state = sjson.encode(mod.getStatus())
            print("Sending", state)
            socket.send(state)
          else
            print("Unknown function", cmd["func"])
          end
        else
          print("Unknown command", cmd["cmd"])
        end
      else
        -- Not a json message
        print("Not a json message, ignoring")
      end
    end
  end)
  return(responseTimer)
end

-- local button control, operates as toggle
-- Borrowed from https://gist.github.com/marcelstoer/59563e791effa4acb65f#file-debounce-with-tmr-lua

local function localControl(callback)

  local function debounce(func)
    local last = 0
    local delay = 50000 -- 50ms * 1000 as tmr.now() has μs resolution

    return function (...)
      local now = tmr.now()
      local delta = now - last
      if delta < 0 then
        delta = delta + 2147483647
      end; -- proposed because of delta rolling over, https://github.com/hackhitchin/esp8266-co-uk/issues/2
      if delta < delay then
        return
      end;

      last = now
      return func(...)
    end
  end

  local function onChange()
    if gpio.read(config.onButton) == 0 then
      mod.onButton()
      callback:start()
    end
  end

  local function colorChange()
    if gpio.read(config.colorButton) == 0 then
      mod.colorButton()
      callback:start()
    end
  end
  gpio.mode(config.onButton, gpio.INT, gpio.PULLUP)
  gpio.mode(config.colorButton, gpio.INT, gpio.PULLUP)
  gpio.trig(config.onButton, "both", debounce(onChange))
  gpio.trig(config.colorButton, "both", debounce(colorChange))
end

local function wifi_ready()
  print("\n====================================")
  print("Name is:         "..config.ID)
  print("ESP8266 mode is: " .. wifi.getmode())
  print("MAC address is: " .. wifi.ap.getmac())
  print("IP is "..wifi.sta.getip())
  print("====================================")
  setup = nil
  wifi.eventmon.unregister(wifi.eventmon.STA_GOT_IP)

  tmr.softwd(600)
  led.connected()
  if string.find(config.Model, "CLED") then
    mod = require('cled_strip')
  end
  package.loaded["main"] = nil
  print("Running " .. config.Model )
  mod.init("null")
  mdns.register(config.ID, {service = config.mdnsName})
  localControl(start())

end

return {entry = function(msg)
  -- Start of code, reboot if not connected within 60 seconds
  tmr.softwd(60)
  print("Starting mculed") -- 38984
  config = require("config-"..wifi.sta.gethostname())
  package.loaded["config-"..wifi.sta.gethostname()] = nil
  led = require("led")
  led.boot()
  wifi_ready()
end}
