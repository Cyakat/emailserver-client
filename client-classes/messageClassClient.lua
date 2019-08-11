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

  print("Type the number of the message you would like to view and press enter to view that message:\n1. "..shortMessage1.."\n2. "..shortMessage2.."\n3. "..shortMessage3.."\n4. "..shortMessage4.."\n5. "..shortMessage5)
  viewMessage = io.read()

  if viewMessage == "exit" then
    encryptedViewMessage = encrypt(viewMessage)
    m.broadcast(1,encryptedViewMessage)
    return true
  else
    return false
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

messageClass = {
  loadPreviews = loadMessagePreviews,
  load = loadMessage,
  view = viewMessages,
  send = sendMessage
}
