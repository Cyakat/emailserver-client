local comp = require("component")
local fs = require("filesystem")
local event = require("event")
local endc = require("endc")
local logging = require("logging")

local m = comp.modem
local str = string

local addressTable = {}

logging.debug("waiting for any response")
_,_,address,_,_,info = event.pull("modem")

function findCorrespondingServer(address, type)
  if type == "user" then
    for i = 0,addressTable.length-1,1 do
      if address == addressTable.[i].[0] then
        serverAddress = addressTable.[i].[1]
        break
      end
    end

    return serverAddress
  elseif type == "server" then
    for i = 0,addressTable.length-1,1 do
      if address == addressTable.[i].[1] then
        serverAddress = addressTable.[i].[0]
        break
      end
    end

    return serverAddress
  end
end

function assignAddress()
  m.close(1)
  m.open(1337)
  m.broadcast(1337, "needServer")
  logging.debug("waiting for an available server")
  notFound = true
  while found do
    _,_,serverAddress,_,_, data = event.pull("modem")
    if data == "available" then
      notFound = false
    end
  end
  logging.debug("received server")
  logging.debug("assigning User to server")
  assignDestinationTable(address, serverAddress)
  logging.debug("assigned User to server")
  logging.debug("waiting for user's data")
end

function sendUserDataToServer(serverAddress, data)
  m.broadcast(1337, serverAddress)
  m.broadcast(1337, data)
end

function sendUserDataToServer(address, data)
  m.broadcast(1, address)
  m.broadcast(1, data)
end

function checkKnownUserAddress(address)
  for i = 0,addressTable.length-1,1 do
    if address == addressTable.[i].[0] then
      knownUser = true
      break
    end
  end

  return knownUser

if info == "in" then
  logging.debug("received in request")
  knownUser = checkKnownUserAddress(address)
  if knownUser then
    logging.debug("received user")
    logging.debug("waiting for data")
    while addressTest != address do
      _,_,addressTest,_,_, data = event.pull("modem")
    end
    logging.debug("received user data")
    logging.debug("sending user data to server")
    serverAddress = findCorrespondingServer(address, "user")
    sendUserDataToServer(serverAddress, data)
  else
    logging.debug("assigning new server to client")
    assignAddress()
    logging.debug("server assigned")
  end
elseif info == "out" then
  logging.debug("received out request")
  logging.debug("waiting for data")
  while addressTest != serverAddress do
    _,_,addressTest,_,_, data = event.pull("modem")
  end
  logging.debug("recieved server data")
  address = findCorrespondingServer(serverAddress, "server")
  logging.debug("found corresponding for user")
  sendServerDataToUser(address, data)
  logging.debug("server data sent to user")
end
