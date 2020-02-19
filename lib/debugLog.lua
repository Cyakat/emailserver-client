local debugLog = {}

debugLog.debugOn = true
debugLog.infoOn = true
debugLog.warningOn = true
debugLog. warnOn = true
debugLog.errorOn = true
debugLog.criticalOn = true

function debugLog.debug(string)
  if debugOn then
    print(string)
  end
end

function debugLog.info(string)
  if infoOn then
    print(string)
  end
end

function debugLog.warning(string)
  if warningOn then
    print(string)
  end
end

function debugLog.warn(string)
  if warnOn then
    print(string)
  end
end

function debugLog.error(string)
  if errorOn then
    pring(string)
  end
end

function debugLog.critical(string)
  if criticalOn then
    print(string)
  end
end

return debugLog
