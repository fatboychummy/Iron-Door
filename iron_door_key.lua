local args = {...}
local lock_port = 20319
local port = 19273
local modem = peripheral.find("modem")
os.loadAPI("strutils")
-- wget https://raw.githubusercontent.com/Xtansia/Lua-String-Utils-API/master/StrUtilsAPI.lua strutils
 
 
function request_iron_door()
    modem.transmit(lock_port, port, settings.get("password"))
end
 
 
function save_key()
    modem.open(port)
    settings.set("lock_id", args[1])
    modem.transmit(lock_port, port, args[1])
    print("Waiting for response from Iron Door server. If this message remains after some time, terminate the program.")
    event, side, frequency, replyFrequency, message, distance = os.pullEvent("modem_message")  
    term.clear()  
    settings.set("password", strutils.SHA1(message .. args[2]))
    modem.close(port)
end
 
 
if args[1] == nil then
    request_iron_door()
else
    save_key()
    request_iron_door()
end
