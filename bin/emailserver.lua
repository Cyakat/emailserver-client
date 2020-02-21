fs = require("filesystem")
comp = require("component")
event = require("event")
messageClass = require("messageClassServer")
logging = require("logging")

logging.level("debug")
m = comp.modem
d = comp.data
str = string

--starting size: 6139

function scanRaids(user)
  logging.debug("scanning drives for user")
  componentList = component.list()
  hhds = fs.mounts()

function startup ()
  m.open(1337)
  logging.info("generating key pari")
  publicKey,privateKey = d.generateKeyPair(256)

  publicKeySerialized = publicKey.serialize()
  privateKeySerialized = privateKey.serialize()
end

function checkIfWanted()

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
  logging.info("Decrypting")
  decryptedText = d.decrypt(text, sharedKey, iv)
  return decryptedText
end

function encrypt (text)
  logging.info("Encrypting")
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
  logging.debug("listening for encrypted username")
  if checkIfWanted() then
    _,_,_,_,_, encryptedUser = event.pull("modem")
  end

  logging.debug("listening for encrypted password")
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
  logging.info("asking if user would like to make an account")
  makeAccount = encrypt("accountCreate")
  m.broadcast(1337,"out")
  m.broadcast(1337,makeAccount)
  logging.info("waiting for user response")
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


      logging.info("sending preview messages")
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
        logging.info("asking send or read")
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
