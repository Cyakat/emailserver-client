local comp = require("component")
local event = require("event")
local fs = require("filesystem")

local m = comp.modem
local str = string
local destinationTable = {
  "userNumericalAddress",
  "userNumericalAddress2"
}
local failed
local defaultDir = "./email/"
local serversInSystem = 10
local serverTable = {}
local userTable = {}

local function startup ()
  m.open(1)
  m.open(1337)

  loadServers()
  assignServerAddress()
end

local function assignDestinationTable(serverAddress, userNumericalAddress, terminateConnection)
  if terminateConnection == nil then
    terminateConnection = false
  end
  for local i = 1,table.getn(destinationTable),1 do
    if destinationTable[i] == nil then
      destinationTable[i] = userNumericalAddress
      break
    elseif destinationTable[i] == userNumericalAddress and terminateConnection then
      destinationTable[i] = nil
      break
    end
  end
end
--[[
local function userAssignAddress(userAddress, terminateConnection)
  if terminateConnection == nil then
    terminateConnection = false
  end
  if table.getn(userTable) ~= 0 then
    for local i = 1,table.getn(userTable),1 do
      if userTable[i] == nil then
        userTable[i] = userAddress
        break
      elseif userTable[i] == userAddress and terminateConnection then
        userTable[i] = nil
        break
      end
    end
  end
end
]]
local function getUserAddress(userAddress, terminateConnection)
  if terminateConnection == nil then
    terminateConnection = false
  end
  local userNumericalAddress
  local exists
  for local i=1,table.getn(userTable),1 do
    if userAddress == userTable[i] then
      userNumericalAddress = tostring(i)
      exists = true
      broadcastAddress = false
      break
    else
      exists = false
    end
    if userAddress == userTable[i] and terminateConnection then
      userTable[i] = nil
      broadcastAddress = false
      break
    end
  end
  if exists == false then
    for local i = 1,table.getn(userTable), do
      if userTable[i] == nil then
        userTable[i] = userAddress
      end
    end
    broadcastAddress = true
  end
  if broadcastAddress then
    m.broadcast(1,userNumericalAddress)
  end

  return userNumericalAddress
end

local function loadServers()
  local location
  local addresses2
  local addresses, size = readFile(defaultDir, "serverAdresses.txt")

  for local i=1,serversInSystem,1 do
    location = str.find(addresses, "\n")
    addresses2 = str.gsub("\n","",1)
    location2 = str.find(addresses2,"\n")
    addresses = str.gsub("\n", "",1)

    serverTable[i] = str.sub(addresses, location, location2-1)
  end
end

local function assignServerAddress()
  for local i = 1,table.getn(serverTable),1 do
    m.send(1337, serverTable[i], i)
  end
end

local function checkFromServer(address)
  local isSever

  for local i=1,serversInSystem,1 do
    if address == addressTable[i] then
      isSever = true
      break
    else
      isSever = false
    end
  end

  return isSever
end

local function sendToServer(serverAddress, message)
  m.broadcast(1337, serverAddress)
  m.broadcast(1337, message)
end

local function sendToUser(serverAddress, message)
  m.broadcast(1, destinationTable[serverAddress])
  m.broadcast(1, message)
end

local function writeFile(directory, fileName, text)
  file = io.open(directory..fileName, "w")
  file: write(text)
  file: close()
end

local function readFile (directory, fileName)
  file = io.open(directory..fileName, "r")
  size = fs.size(directory..fileName)
  text = file: read(size)

  return text, size
end

local function main ()
  print("listening for incoming requests")
  local _,_, address,_,_, info = event.pull("modem")

  local _,_,_,_,_, message = event.pull("modem")

  if info ==  "in" then
    ::again::
    if table.getn(destinationTable) ~= 0 then
      local userNumericalAddress = getUserAddress(address)
      for local i = 1,table.getn(destinationTable),1 do
        if userNumericalAddress == destinationTable[i] then
          sendToServer(i, message)
          failed = false
          break
        else
          failed = true
        end
      end
      if failed then
        userNumericalAddress = getUserAddress(address)
        assignDestinationTable(i, userNumericalAddress)
      end
    else
      userNumericalAddress = getUserAddress(address)
      destinationTable[1] = userNumericalAddress
      goto again
    end
  elseif info == "out" then
    isServer = checkFromServer(address)
    if isServer then
      for local i = 1,table.getn(destinationTable),1 do
        if address == serverTable[i] then
          sendToUser(i, message)
          break
        end
      end
    else
      m.broadcast(1,"invalid request")
    end
  end
end

startup()
main()
