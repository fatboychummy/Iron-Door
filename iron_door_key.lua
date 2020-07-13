local args = {...}
local lock_port = 20319
local modem = peripheral.find("modem")
os.loadAPI("aeslua")
modem.transmit(lock_port, 10923, aeslua.encrypt(args[1], args[1]))
term.clear()