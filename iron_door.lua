local args = {...}
local port = 20319
os.loadAPI("aeslua");
local modem = peripheral.find("modem")


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
    open_door = not settings.get("open")
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
        print("Please enter your password.")     
        if io.read() == settings.get("password") then
            output_to_door()        
        end
    end            
end
 
 
function wireless_init()
	if modem == nil then
		print("A modem must be attached for wireless capabilities.")
		return
	end
    modem.open(port)
	term.clear()
    print("This door is now listening for access requests.")
    while true do
        event, side, frequency, replyFrequency, message, distance = os.pullEvent("modem_message")	
        pwd = settings.get("password")
        if aeslua.decrypt(pwd, message) == pwd then
            output_to_door()        
        end
    end
end
 
 
function save_lock()
    settings.set("password", args[1])
    settings.set("behavior", args[2])
    settings.set("output_side", args[3])
    settings.set("wireless", to_boolean(args[4]))
    settings.set("open", false)
end


function init()
	if settings.get("password") == nil then
		print("Iron door has not been configured!")
		print("Usage: irondoor <password> <behavior> <side> <wireless>")
		return
	end
	if settings.get("wireless") then
		wireless_init()
	else
    	local_init()
	end
end
 

if args[1] ~= nil then
    save_lock()
	init()
else
	init()
end