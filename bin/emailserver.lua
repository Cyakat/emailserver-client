fs = require("filesystem")
comp = require("component")
event = require("event")
messageClass = require("messageClassServer")

m = comp.modem
d = comp.data
str = string
defaultDir = "./email/users/"
assignedAddress = ""

--starting size: 6139

function startup ()
  m.open(1337)
  print("generating key pair")
  publicKey,privateKey = d.generateKeyPair(256)

  publicKeySerialized = publicKey.serialize()
  privateKeySerialized = privateKey.serialize()
  addressAssigned()
end

function addressAssigned()
  m.broadcast(1, "needAddress")
  m.broadcast(1, "lolgay")
  _,_,_,_,_, assignedAddress = event.pull("modem")
end

function checkIfWanted()
  _,_,_,_,_, address = event.pull("modem")
  if address == assignedAddress then
    wanted = true
  else
    wanted = false
  end

  return wanted
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

function getKeyAndIv ()
  if checkIfWanted() then
    _,_,_,_,_, outerPublicKeySerialized = event.pull("modem")
  end
  m.broadcast(1337,"out")
  m.broadcast(1337,publicKeySerialized)

  if checkIfWanted() then
    _,_,_,_,_, iv = event.pull("modem")
  end

  return outerPublicKeySerialized, iv
end

function signIn ()
  print("listening for encrypted username")
  if checkIfWanted() then
    _,_,_,_,_, encryptedUser = event.pull("modem")
  end

  print("listening for encrypted password")
  if checkIfWanted() then
    _,_,_,_,_, encryptedPassword = event.pull("modem")
  end

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
  m.broadcast(1337,out)
  m.broadcast(1337,makeAccount)
  print("waiting for user response")
  if checkIfWanted() then
    _,_,_,_,_, encryptedResponse = event.pull("modem")
  end

  response = decrypt(encryptedResponse)

  if response == "true" then
    local userDir = defaultDir..user.."/"
    fs.makeDirectory(userDir)
    if checkIfWanted() then
      _,_,_,_,_, encryptedPassword = event.pull("modem")
    end

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
      m.broadcast(1337, "out")
      m.broadcast(1337,encryptedMatch)

      encryptedMessage1, encryptedShortMessage1 = messageClass.load(1)
      encryptedMessage2, encryptedShortMessage2 = messageClass.load(2)
      encryptedMessage3, encryptedShortMessage3 = messageClass.load(3)
      encryptedMessage4, encryptedShortMessage4 = messageClass.load(4)
      encryptedMessage5, encryptedShortMessage5 = messageClass.load(5)


      print("sending preview messages")
      m.broadcast(1337, "out")
      m.broadcast(1337, encryptedShortMessage1)
      m.broadcast(1337, "out")
      m.broadcast(1337, encryptedShortMessage2)
      m.broadcast(1337, "out")
      m.broadcast(1337, encryptedShortMessage3)
      m.broadcast(1337, "out")
      m.broadcast(1337, encryptedShortMessage4)
      m.broadcast(1337, "out")
      m.broadcast(1337, encryptedShortMessage5)

      sendOrRead = "hi"
      while sendOrRead ~= "exit" do
        print("asking send or read")
        if checkIfWanted() then
          _,_,_,_,_, encryptedSendOrRead = event.pull("modem")
        end

        sendOrRead = decrypt(encryptedSendOrRead)

        if sendOrRead == "read" then
          messageClass.view()
          sendOrRead = "hi"
        elseif sendOrRead == "send" then
          message = messageClass.write()
          messageClass.update()
          encryptedMessage1, encryptedMessage2, encryptedMessage3, encryptedMessage4, encryptedMessage5 = messageClass.refresh()

          sendOrRead = "hi"
        elseif sendOrRead == "exit" then
          sendOrRead = "exit"
        end
      end
    else
      match = "noMatch"
      encryptedMatch = encrypt(match)

      m.broadcast(1337, "out")
      m.broadcast(1337,encryptedMatch)
    end
  end
end

startup()

while true do
  main()
end
