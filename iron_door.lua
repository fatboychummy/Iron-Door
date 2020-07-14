local args = {...}
local port = 20319
local modem = peripheral.find("modem")
os.loadAPI("strutils")
-- wget https://raw.githubusercontent.com/Xtansia/Lua-String-Utils-API/master/StrUtilsAPI.lua strutils
 
 
function print_credits()
    print("Iron Door by sunsetdev")
    print("https://github.com/sunset-developer")
    print("------------------------------------")
end
 
 
function salt()
    local length = 20
    local string = ""
    local keys = {"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"}
    for i = 1, length do
        upper = math.random(1,2)
        if upper == 1 then
            string = string..keys[math.random(1,#keys)]:upper()
        else
            string = string..keys[math.random(1,#keys)]
        end
    end
    return string
end
 
 
function if_ternary(cond, true_var, false_var)
    if cond then return true_var else return false_var end
end
 
 
function to_boolean(str)
    if str == "true" then return true else return false end
end
 
 
function button()
    redstone.setOutput(settings.get("output_side"), true)
    os.sleep(1)
    redstone.setOutput(settings.get("output_side"), false)
end
 
 
function output_to_door()
    local open_door = not settings.get("open")
    if settings.get("behavior") == "button" then
        button()
    else
        redstone.setOutput(settings.get("output_side"), open_door)
    end
    settings.set("open", open_door)  
end
 
 
function local_init()
    while true do  
        term.clear()  
        print_credits()
        print("Please enter your password.")    
        if strutils.SHA1(settings.get("salt") .. io.read()) == settings.get("password") then
            output_to_door()        
        end
    end            
end
 
 
function wireless_init()
    modem.open(port)
    term.clear()
    print_credits()
    print("This door is now listening for access requests.")
    while true do
        event, side, frequency, replyFrequency, message, distance = os.pullEvent("modem_message")
        if message == tostring(os.getComputerID()) then
            modem.transmit(replyFrequency, port, settings.get("salt"))
        else
            if message == settings.get("password") then output_to_door() end
        end
    end
end
 
 
function init()
    if settings.get("password") == nil then
        print("Usage: irondoor <password> <behavior> <side> <wireless>")
        return
    end
    if settings.get("wireless") then
        if modem == nil then
            print("A modem must be attached for wireless capabilities.")
            return
        end
        wireless_init()
    else
        local_init()
    end
end
 
 
function save_lock()
    local salt = salt()
    settings.set("salt", salt)
    settings.set("password", strutils.SHA1(salt .. args[1]))
    settings.set("behavior", args[2])
    settings.set("output_side", args[3])
    settings.set("wireless", to_boolean(args[4]))
    settings.set("open", false)
end
 
 
if args[1] == nil then
    init()
else
    save_lock()
    init()
end
