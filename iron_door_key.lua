local args = {...}
local lock_port = 20319
local port = 19273
local modem = peripheral.find("modem")
os.loadAPI("strutils")
-- wget https://raw.githubusercontent.com/Xtansia/Lua-String-Utils-API/master/StrUtilsAPI.lua strutils
 
 
function request_iron_door()
    if settings.get("lock_id") == nil then
        print("Usage: irondoorkey <lock id> <password>")
        return
    end
    modem.transmit(lock_port, port, settings.get("password"))
end
 
 
function save_key()
    modem.open(port)
    settings.set("lock_id", args[1])
    modem.transmit(lock_port, port, args[1])
    print("Waiting for response from Iron Door server.")
    local event, side, frequency, replyFrequency, message, distance
    parallel.waitForAny(function()
        event, side, frequency, replyFrequency, message, distance = os.pullEvent("modem_message")
    end,
    function()
        os.sleep(1)
        event = false
    end)
    if event then
        term.clear()  
        settings.set("password", strutils.SHA1(message .. args[2]))
        modem.close(port)
    else
        printError("Did not receive reply.")
        os.sleep(1)
    end
end
 
 
if args[1] == nil then
    request_iron_door()
else
    save_key()
    request_iron_door()
end
    modem.transmit(lock_port, port, settings.get("password"))
end
