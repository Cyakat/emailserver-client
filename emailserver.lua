local fs = require("filesystem")
local comp = require("component")
local event = require("event")

m = comp.modem
d = comp.data
str = string
defaultDir = "./email/users/"

--starting size: 6139

function startup ()
  m.open(1)
  print("generating key pair")
  publicKey,privateKey = d.generateKeyPair(256)

  publicKeySerialized = publicKey.serialize()
  privateKeySerialized = privateKey.serialize()
end

function generateSharedKey (outerPublicKey, privateKey)
  local sharedKey = d.ecdh(privateKey, outerPublicKey)
  local shortKey = str.sub(sharedKey,0,16)

  return shortKey
end

function deserialize (key, type)
  if type == "public" then
    tableKey = d.deserializeKey(key, "ec-public")
  end
  if type == "private" then
    tableKey = d.deserializeKey(kye, "ec-private")
  end
  return tableKey
end

function writeFile(directory, fileName, text)
  file = io.open(directory..fileName, "w")
  file: write(text)
  file: close()
end

function readFile (directory, fileName)
  file = io.open(directory..fileName, "r")
  size = fs.size(directory..fileName)
  text = file: read(size)

  return text
end

function decrypt (text)
  print("Decrypting")
  decryptedText = d.decrypt(text, sharedKey, iv)
  return decryptedText
end

function encrypt (text)
  print("Encrypting")
  encryptedText = d.encrypt(text, sharedKey, iv)
  return encryptedText
end

function refresh ()
  userDir = defaultDir..user.."/"
  message1 = readFile(userDir, "message1")
  message2 = readFile(userDir, "message2")
  message3 = readFile(userDir, "message3")
  message4 = readFile(userDir, "message4")
  message5 = readFile(userDir, "message5")

  encryptedMessage1 = encrypt(message1)
  encryptedMessage2 = encrypt(message2)
  encryptedMessage3 = encrypt(message3)
  encryptedMessage4 = encrypt(message4)
  encryptedMessage5 = encrypt(message5)

  return encryptedMessage1, encryptedMessage2, encryptedMessage3, encryptedMessage4, encryptedMessage5
end

function getKeyAndIv ()
  _,_,_,_,_, outerPublicKeySerialized = event.pull("modem")
  m.broadcast(1,publicKeySerialized)

  _,_,_,_,_, iv = event.pull("modem")

  return outerPublicKeySerialized, iv
end

function signIn ()
  print("listening for encrypted username")
  _,_,_,_,_, encryptedUser = event.pull("modem")

  print("listening for encrypted password")
  _,_,_,_,_, encryptedPassword = event.pull("modem")

  print(encryptedPassword.."\n")
  print(encryptedUser.."\n")

  password = decrypt(encryptedPassword)
  print(password)
  user = decrypt(encryptedUser)
  print(user)
end

function accountCreate ()
  local blank = "nothing"
  print("asking if user would like to make an account")
  makeAccount = encrypt("accountCreate")
  m.broadcast(1,makeAccount)
  print("waiting for user response")
  _,_,_,_,_, encryptedResponse = event.pull("modem")

  response = decrypt(encryptedResponse)

  if response == "true" then
    local userDir = defaultDir..user.."/"
    fs.makeDirectory(userDir)
    _,_,_,_,_, encryptedPassword = event.pull("modem")

    password = decrypt(encryptedPassword)

    writeFile(userDir, "password", password)

    writeFile(userDir, "message1", blank)
    writeFile(userDir, "message2", blank)
    writeFile(userDir, "message3", blank)
    writeFile(userDir, "message4", blank)
    writeFile(userDir, "message5", blank)

  end
end

function checkPassword ()
  file = io.open(defaultDir..user.."/password","r")
  size = fs.size(defaultDir..user.."/password")
  realPassword = file: read(size)

  return realPassword
end

function loadMessage(messageNumber)
  messageNumber = tostring(messageNumber)

  file = io.open(defaultDir..user.."/message"..messageNumber,"r")
  size = fs.size(defaultDir..user.."/message"..messageNumber)
  message = file: read(size)

  shortMessage = str.sub(message,0,20)
  shortMessage = shortMessage.."..."

  encryptedShortMessage = encrypt(shortMessage)
  encryptedMessage = encrypt(message)

  return encryptedMessage, encryptedShortMessage
end

function viewMessages ()
  response = "hello"
  while response ~= "exit" do
    print("waiting for response")
    _,_,_,_,_, encryptedResponse = event.pull("modem")

    response = decrypt(encryptedResponse)

    if response == "1" then
      print("sending message1")
      m.broadcast(1, encryptedMessage1)
    elseif response == "2" then
      print("sending message2")
      m.broadcast(1, encryptedMessage2)
    elseif response == "3" then
      print("sending message3")
      m.broadcast(1, encryptedMessage3)
    elseif response == "4" then
      print("sending message4")
      m.broadcast(1, encryptedMessage4)
    elseif response == "5" then
      print("sending Message5")
      m.broadcast(1, encryptedMessage5)
    else
      repsonse = "exit"
    end
  end
end

function updateMessages ()
  message2 = readFile(userDir, "message1")
  message3 = readFile(userDir, "message2")
  message4 = readFile(userDir, "message3")
  message5 = readFile(userDir, "message4")

  writeFile(userDir, "message2", message2)
  writeFile(userDir, "message3", message3)
  writeFile(userDir, "message4", message4)
  writeFile(userDir, "message5", message5)
  writeFile(userDir, "message1", message)
end

function writeMessage()
  print("waiting for user address")
  _,_,_,_,_, encryptedUser = event.pull("modem")

  username = decrypt(encryptedUser)

  print("waiting for encrypted message")
  _,_,_,_,_, encryptedMessage = event.pull("modem")

  userDir = defaultDir..username.."/"

  message = decrypt(encryptedMessage)
  message = user..": "..message

  print("message sent to "..username)

  updateMessages()

  encryptedMessage1, encryptedMessage2, encryptedMessage3, encryptedMessage4, encryptedMessage5 = refresh()
end

function main ()
  outerPublicKeySerialized, iv = getKeyAndIv()
  sharedKey = generateSharedKey(deserialize(outerPublicKeySerialized, "public"), privateKey)

  match = signIn()

  if fs.isDirectory(defaultDir..user) == false then
    accountCreate()
  else

    realPassword = checkPassword()

    if realPassword == password then
      match = "match"
      encryptedMatch = encrypt(match)
      m.broadcast(1,encryptedMatch)

      encryptedMessage1, encryptedShortMessage1 = loadMessage(1)
      encryptedMessage2, encryptedShortMessage2 = loadMessage(2)
      encryptedMessage3, encryptedShortMessage3 = loadMessage(3)
      encryptedMessage4, encryptedShortMessage4 = loadMessage(4)
      encryptedMessage5, encryptedShortMessage5 = loadMessage(5)


      print("sending preview messages")
      m.broadcast(1, encryptedShortMessage1)
      m.broadcast(1, encryptedShortMessage2)
      m.broadcast(1, encryptedShortMessage3)
      m.broadcast(1, encryptedShortMessage4)
      m.broadcast(1, encryptedShortMessage5)

      sendOrRead = "hi"
      while sendOrRead ~= "exit" do
        print("asking send or read")
        _,_,_,_,_, encryptedSendOrRead = event.pull("modem")

        sendOrRead = decrypt(encryptedSendOrRead)

        if sendOrRead == "read" then
          viewMessages()
          sendOrRead = "hi"
        elseif sendOrRead == "send" then
          writeMessage()
          sendOrRead = "hi"
        elseif sendOrRead == "exit" then
          sendOrRead = "exit"
        end
      end
    else
      match = "noMatch"
      encryptedMatch = encrypt(match)

      m.broadcast(1,encryptedMatch)
    end
  end
end

startup()

while true do
  main()
end
