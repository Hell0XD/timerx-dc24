
local appName = "TimerX"

local time = system.getTimeCounter()
local running = false
local startTime = system.getTimeCounter()

local times = {}

local function stop() 
  running = false
end

local function save() 
  if (time - startTime) > 20 * 1000 then
    table.insert(times, time - startTime)
    stop()
  end
end

local function start() 
  if (time - startTime) > 60 * 1000 then
    save()
  end
  running = true

  startTime = system.getTimeCounter()
end

local function formatTimeMs(time)
  return string.format("%02d:%02d:%02d", time // 1000 // 60, time // 1000 % 60, math.abs(time) % 60)
end

local saveSwitch 
local saveSwitchOn
local saveSwitchPrev

local function onSavechange(value) 
  saveSwitch = system.getInputsVal(value) ~= 0.0 and value or nil
  saveSwitchOn = system.getInputsVal(value)
  saveSwitchPrev = saveSwitchOn

  system.pSave("xTimer:save", saveSwitch)
  system.pSave("xTimer:saveOn", saveSwitchOn)
  system.pSave("xTimer:savePrev", saveSwitchPrev)
end

local startSwitch 
local startSwitchOn
local startSwitchPrev

local function onStartchange(value) 
  startSwitch = system.getInputsVal(value) ~= 0.0 and value or nil
  startSwitchOn = system.getInputsVal(value)
  startSwitchPrev = startSwitchOn

  system.pSave("xTimer:start", startSwitch)
  system.pSave("xTimer:startOn", startSwitchOn)
  system.pSave("xTimer:startPrev", startSwitchPrev)
end


local function initForm()
  form.addRow(2)
  form.addLabel({ label = "Save Switch" })
  form.addInputbox(saveSwitch, false, onSavechange)

  form.addRow(2)
  form.addLabel({ label = "Start Switch" })
  form.addInputbox(startSwitch, false, onStartchange)

  form.setButton(1, "RESET", ENABLED)
end

local function keyPressed(key)
  if(key==KEY_1) then
    times = {}
    system.messageBox("Times reset")
  end
end

local function printForm()
end


local function formatNumber(i)
  local str = tostring(i)
  if string.len(str) == 1 then
    return "0"..str
  end

  return str
end

local function printTelemetry(width, height)   
  local tmp = time - startTime
  local text = formatTimeMs(tmp)
  lcd.drawText(width - lcd.getTextWidth(FONT_BIG, text) - 2, 0, text, FONT_BIG)

  lcd.drawText(2,0,"Times", FONT_BIG)

  lcd.drawLine(0, 20, width, 20)

  for i, t in ipairs(times) do
    row = math.floor((i - 1) / 6)
    col = ((i - 1) % 6)
    lcd.drawText(35 + row * 150,25 + col * 20, formatNumber(i) .. ". " .. formatTimeMs(t), FONT_BIG)
  end
end 



local function loop()
  local nextValStart = system.getInputsVal(startSwitch)

  if startSwitch ~= nil then
    if startSwitchPrev ~= nextValStart and startSwitchOn == nextValStart then
      start()
    end
  end

  startSwitchPrev = nextValStart

  if running == true then
    time = system.getTimeCounter()

    local nextVal = system.getInputsVal(saveSwitch)
    
    if saveSwitch ~= nil then
      if saveSwitchPrev ~= nextVal and saveSwitchOn == nextVal then
        save()
      end
    end
    saveSwitchPrev = nextVal
  end
end


local function init()
  saveSwitch = system.pLoad("xTimer:save", nil)
  saveSwitchOn = system.pLoad("xTimer:saveOn", nil)
  saveSwitchPrev = system.pLoad("xTimer:savePrev", nil)

  startSwitch = system.pLoad("xTimer:start", nil)
  startSwitchOn = system.pLoad("xTimer:startOn", nil)
  startSwitchPrev = system.pLoad("xTimer:startPrev", nil)

  system.registerForm(1,MENU_APPS,appName,initForm,keyPressed,printForm)
  system.registerTelemetry(2, "TimerX", 4, printTelemetry)
end
--------------------------------------------------------------------------------

return {init=init,loop=loop,author="Max Müller",name=appName, version="1.0"}
