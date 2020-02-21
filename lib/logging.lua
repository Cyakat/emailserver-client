local logging = {}

function logging.level(level)
  if level == "debug" then
    logging.debugOn = true
    logging.infoOn = true
    logging.warningOn = true
    logging.warnOn = true
    logging.errorOn = true
    logging.criticalOn = true
  elseif level == "info" then
    logging.debugOn = false
    logging.infoOn = true
    logging.warningOn = true
    logging.warnOn = true
    logging.errorOn = true
    logging.criticalOn = true
  elseif level == "warn" then
    logging.debugOn = false
    logging.infoOn = false
    logging.warningOn = true
    logging.warnOn = true
    logging.errorOn = true
    logging.criticalOn = true
  elseif level == "warning" then
    logging.debugOn = false
    logging.infoOn = false
    logging.warningOn = true
    logging.warnOn = false
    logging.errorOn = true
    logging.criticalOn = true
  elseif level == "error" then
    logging.debugOn = false
    logging.infoOn = false
    logging.warningOn = false
    logging.warnOn = false
    logging.errorOn = true
    logging.criticalOn = true
  elseif level == "critical" then
    logging.debugOn = false
    logging.infoOn = false
    logging.warningOn = false
    logging.warnOn = false
    logging.errorOn = false
    logging.criticalOn = true
  end
end

function logging.debug(string)
  if logging.debugOn then
    print("DEBUG: "..string)
  end
end

function logging.info(string)
  if logging.infoOn then
    print("INFO: "..string)
  end
end

function logging.warning(string)
  if logging.warningOn then
    print("WARNING: "..string)
  end
end

function logging.warn(string)
  if logging.warnOn then
    print("WARN: "..string)
  end
end

function logging.error(string)
  if logging.errorOn then
    pring("ERROR: "..string)
  end
end

function logging.critical(string)
  if logging.criticalOn then
    print("CRITICAL: "..string)
  end
end

return logging
