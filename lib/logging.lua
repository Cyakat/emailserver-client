local logging = {}

logging.debugOn = true
logging.infoOn = true
logging.warningOn = true
logging. warnOn = true
logging.errorOn = true
logging.criticalOn = true

function logging.debug(string)
  if debugOn then
    print(string)
  end
end

function logging.info(string)
  if infoOn then
    print(string)
  end
end

function logging.warning(string)
  if warningOn then
    print(string)
  end
end

function logging.warn(string)
  if warnOn then
    print(string)
  end
end

function logging.error(string)
  if errorOn then
    pring(string)
  end
end

function logging.critical(string)
  if criticalOn then
    print(string)
  end
end

return logging
