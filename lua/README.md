# homebridge-mculed ESP8266 LUA Code

LUA programs for a nodeMCU device to control a RGB+W LED Strip

# Hardware

1. Bill of materials
   - nodeMCU / esp8266 dev kit
   - 74HCT245
   - 1000uf 25V capacitor
   - 470 Ohm Resistor
   - DC to DC Power Converter
   - 2 x Push Button switch
   - FQP30N06L N-Channel MOSFET

# Circuit Diagrams

## CLED/Costco LED Strip

![CLED](mculed_v2_schem.jpg)

![CLED](mculed_v2_perf_bb.jpg)

![Breadboard](IMG_2846-2.JPG)

![Perfboard](IMG_2857.jpg)

![Perfboard](IMG_2862.jpg)

# Tools

* nodemcu-uploader - Install instructions are here https://github.com/kmpm/nodemcu-uploader
* lua - Install instructions are here https://www.lua.org/download.html
* esptool - Install instructions are here https://github.com/espressif/esptool
* esplorer - Install instructions are here https://esp8266.ru/esplorer/

# nodeMCU Firmware

1. Using http://nodemcu-build.com, create a custom firmware containing at least
   these modules:

   `bit,color_utils,crypto,file,gpio,mdns,net,node,pwm,sjson,tmr,uart,websocket,wifi,ws2812,ws2812_effects`


2. Please use esptool to install the float firmware onto your nodemcu.  There are alot of guides for this, so I won't repeat it here.

# Configuration

1. WIFI Setup - Copy luaOTA/passwords_sample.lua to luaOTA/passwords.lua and add your wifi SSID and passwords.  Please note
   that the configuration supports multiple wifi networks, one per config line.
```
module.SSID["SSID1"] = { ssid="SSID1", pwd = "password" }
```

2. Copy config-NODE-AC545F.lua to your nodemcu's name, and change the config to your model

```
module.Model = "CLED"
```

3. Copy ESP-NODE-AC545f.json to your nodemcu's name, and update the file to include your config file.

# Lua Program installation

1. I used nodemcu-uploader which is available here https://github.com/kmpm/nodemcu-uploader

2. Run the script lua/luaScript/initialUpload.sh, this will upload all the lua ota provisioning files to your esp8266

3. Start the OTA server with the script, startOtaServer.sh

4. Using esplorer, on the nodemcu, run the lua program initOta.lua

# ESPlorer Snippets

## Memory

```
print("\n------- GLOBALS --------\n")

for k,v in pairs(_G) do print(k,v) end

print("\n-------- REGISTRY -------\n")

for k,v in pairs(debug.getregistry()) do print(k,v) end

print("\n------- PACKAGES --------\n")

table.foreach (package.loaded, print)
```