local fs = require("filesystem")
local comp = require("component")
local event = require("event")

m = comp.modem
d = comp.data
str = string

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

function getKeyAndIv ()
  m.broadcast(1,publicKeySerialized)
  _,_,_,_,_, outerPublicKeySerialized = event.pull("modem")

  iv = d.random(16)
  m.broadcast(1,iv)

  return outerPublicKeySerialized, iv
end

function accountCreate ()
  print("Would you like to make an account? y/n")
  yOrN = io.read()

  if yOrN == "y" then
    response = "true"
    encryptedResponse = encrypt(response)

    m.broadcast(1,encryptedResponse)

    print("Please enter the password you would like to have.")
    password = io.read()

    encryptedPassword = encrypt(password)
    m.broadcast(1,encryptedPassword)

    print("Account created")
  end
end

function loadMessagePreviews ()
  print("Loading message previews")
  _,_,_,_,_, encryptedShortMessage1 = event.pull("modem")
  _,_,_,_,_, encryptedShortMessage2 = event.pull("modem")
  _,_,_,_,_, encryptedShortMessage3 = event.pull("modem")
  _,_,_,_,_, encryptedShortMessage4 = event.pull("modem")
  _,_,_,_,_, encryptedShortMessage5 = event.pull("modem")

  shortMessage1 = decrypt(encryptedShortMessage1)
  shortMessage2 = decrypt(encryptedShortMessage2)
  shortMessage3 = decrypt(encryptedShortMessage3)
  shortMessage4 = decrypt(encryptedShortMessage4)
  shortMessage5 = decrypt(encryptedShortMessage5)
end

function loadMessage(messageNumber)
  encryptedViewMessage = encrypt(tostring(messageNumber))
  m.broadcast(1,encryptedViewMessage)

  print("Recieving message")
  _,_,_,_,_, encryptedMessage = event.pull("modem")

  message = decrypt(encryptedMessage)

  print("Here is your message type exit when you would like to read another message:\n"..message)
  viewMessage = io.read()
end

function viewMessages()
  sendOrRead = "read"

  encryptedSendOrRead = encrypt(sendOrRead)
  m.broadcast(1,encryptedSendOrRead)

  viewMessage = "1"
  while viewMessage ~= "exit" do
    print("Type the number of the message you would like to view and press enter to view that message:\n1. "..shortMessage1.."\n2. "..shortMessage2.."\n3. "..shortMessage3.."\n4. "..shortMessage4.."\n5. "..shortMessage5)
    viewMessage = io.read()

    if viewMessage == "exit" then
      encryptedViewMessage = encrypt(viewMessage)
      m.broadcast(1,encryptedViewMessage)
    else
      loadMessage(viewMessage)
    end
  end
end

function sendMessage ()
  sendOrRead = "send"

  encryptedSendOrRead = encrypt(sendOrRead)
  m.broadcast(1,encryptedSendOrRead)

  print("Please enter the username of the person you would like to send your message to")
  username = io.read()

  encryptedUsername = encrypt(username)
  m.broadcast(1,encryptedUsername)

  print("Please enter the message you would like to send. Hitting enter will send the message. Use \\n for a linebreak instead")
  message = io.read()
  encryptedMessage = encrypt(message)

  m.broadcast(1,encryptedMessage)
end

function signIn ()
  print("Please enter your username")
  user = io.read()

  print("Please enter your password")
  password = io.read()

  encryptedUser = encrypt(user)
  m.broadcast(1,encryptedUser)

  encryptedPassword = encrypt(password)
  m.broadcast(1,encryptedPassword)

  print("Checking if password matches")
  _,_,_,_,_, encryptedMatch = event.pull("modem")

  match = decrypt(encryptedMatch)

  return match
end

function main ()
  outerPublicKeySerialized, iv = getKeyAndIv()
  print(outerPublicKeySerialized)
  outerPublicKey = deserialize(outerPublicKeySerialized, "public")
  print(privateKey)
  print(outerPublicKey)
  sharedKey = generateSharedKey(outerPublicKey, privateKey)

  match = signIn()

  if match == "match" then
    loadMessagePreviews()
    choice = "1"
    while choice ~= "exit" do
      print("Would you like to:\n1. View your messages\n2. Send a message")
      choice = io.read()

      if choice == "1" then
        viewMessages()
      elseif choice == "2" then
        sendMessage()
      elseif choice == "exit" then
        encryptedChoice = encrypt(choice)
        m.broadcast(1,encryptedChoice)
      end
    end
  elseif match == "accountCreate" then
    accountCreate()
  else
    print("The password did not match")
  end
end

startup()
main()
