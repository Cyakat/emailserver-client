local messageClass = {}

d = comp.data
m = comp.modem
str = string

function messageClass.refresh ()
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

function messageClass.load (messageNumber)
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

function messageClass.view ()
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

function messageClass.update ()
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

function messageClass.write ()
  print("waiting for user address")
  _,_,_,_,_, encryptedUser = event.pull("modem")

  username = decrypt(encryptedUser)

  print("waiting for encrypted message")
  _,_,_,_,_, encryptedMessage = event.pull("modem")

  userDir = defaultDir..username.."/"

  message = decrypt(encryptedMessage)
  message = user..": "..message

  print("message sent to "..username)

  return message
end



return messageClass
