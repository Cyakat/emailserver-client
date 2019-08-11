local fs = require("filesystem")
local comp = require("component")
local event = require("event")
local messageClass = require("./client-classes/messageClassClient")

m = comp.modem
d = comp.data
str = string

function encrypt (text)
  print("Encrypting")
  encryptedText = d.encrypt(text, sharedKey, iv)
  return encryptedText
end

function decrypt (text)
  print("Decrypting")
  decryptedText = d.decrypt(text, sharedKey, iv)
  return decryptedText
end

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
    messageClass.loadPreviews()
    choice = "1"
    while choice ~= "exit" do
      print("Would you like to:\n1. View your messages\n2. Send a message")
      choice = io.read()

      if choice == "1" then
        viewMessage = "1"
        while viewMessage ~= "exit" do
          exit = messageClass.view()
          if exit == false then
            messageClass.load()
          end
        end
      elseif choice == "2" then
        messageClass.send()
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
