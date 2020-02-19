local comp = require("component")
local fs = require("filesystem")
local event = require("event")
local endc = require("endc")
local debugLog = require("debugLog")

local m = comp.modem
local str = string

debugLog.debug("waiting for any response")
_,_,address,_,_,info = event.pull("modem")

if info == "in" then
  knownUser =checkKnownUserAddress(address)
  if knownUser then
    _,_,address2,_,_,data = event.pull("modem")
    if address == address2 then
      
