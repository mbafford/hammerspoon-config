-- simplify launching and cycling through app windows
local obj={}
obj.__index = obj
obj.name = "App Launch or Cycle Focus"
obj.version = "0.1"
obj.author = "Matthew Bafford <matthew.bafford@gmail.com>"
obj.homepage = "https://github.com/mbafford/hammerspoon-config"
obj.license = "MIT - https://opensource.org/licenses/MIT"

-- based on https://github.com/oskarols/dotfiles/blob/master/hammerspoon/extensions.lua
-- but modified to support various issues I had with certain applications

function obj:init()
end

dbg = function(...)
  print(hs.inspect(...))
end

dbgf = function (...)
  return dbg(string.format(...))
end

function isFunction(a)
  return type(a) == "function"
end

-- gets propery or method value
-- on a table
function result(obj, property)
  if not obj then return nil end

  if isFunction(property) then
    return property(obj)
  elseif isFunction(obj[property]) then -- string
    return obj[property](obj) -- <- this will be the source of bugs
  else
    return obj[property]
  end
end

local mouseCircle = nil
local mouseCircleTimer = nil

function mouseHighlight()
  -- Delete an existing highlight if it exists
  result(mouseCircle, "delete")
  result(mouseCircleTimer, "stop")

  -- Get the current co-ordinates of the mouse pointer
  mousepoint = hs.mouse.get()

  -- Prepare a big red circle around the mouse pointer
  mouseCircle = hs.drawing.circle(hs.geometry.rect(mousepoint.x-40, mousepoint.y-40, 80, 80))
  mouseCircle:setFillColor({["red"]=0,["blue"]=1,["green"]=0,["alpha"]=0.5})
  mouseCircle:setStrokeWidth(0)
  mouseCircle:show()

  -- Set a timer to delete the circle after 3 seconds
  mouseCircleTimer = hs.timer.doAfter(0.2, function()
    mouseCircle:delete()
  end)
end

-- Needed to enable cycling of application windows
lastToggledApplication = ''

-- Fetch next index but cycle back when at the end
--
-- > getNextIndex({1,2,3}, 3)
-- 1
-- > getNextIndex({1}, 1)
-- 1
-- @return int
local function getNextIndex(table, currentIndex)
  nextIndex = currentIndex + 1
  if nextIndex > #table then
    nextIndex = 1
  end

  return nextIndex
end


-- Returns the next successive window given a collection of windows
-- and a current selected window
--
-- @param  windows  list of hs.window or applicationName
-- @param  window   instance of hs.window
-- @return hs.window
local function getNextWindow(windows, window)
  if windows == nil or #windows == 0 then
    dbgf("getNextWindow: No windows provided.")
    return nil
  end
  windows = hs.fnutils.filter(windows, hs.window.isStandard)
  windows = hs.fnutils.filter(windows, hs.window.isVisible)

  -- need to sort by ID, since the default order of the window
  -- isn't usable when we change the mainWindow
  -- since mainWindow is always the first of the windows
  -- hence we would always get the window succeeding mainWindow
  table.sort(windows, function(w1, w2)
    return w1:id() > w2:id()
  end)

  lastIndex = hs.fnutils.indexOf(windows, window)

  return windows[getNextIndex(windows, lastIndex)]
end


function obj:launchOrCycleFocus(applicationName)
    local focusedWindow  = hs.window.focusedWindow()
    local focusedApp     = hs.application.frontmostApplication()

    -- dbgf("focused window: %s, focused app: %s", focusedWindow, focusedApp);

    local targetApp = hs.application.get(applicationName)
    if not targetApp then
      targetApp = hs.appfinder.appFromName(applicationName)
    end

    -- dbgf('last: %s, new: %s', lastToggledApplication, targetApp)

    if focusedApp:name() == applicationName then
      local focusedAppWindows = focusedApp:allWindows();
      if  focusedAppWindows and #focusedAppWindows >= 1 then
        local nextWindow = getNextWindow(focusedAppWindows, focusedWindow)
        nextWindow:becomeMain()
      end
    elseif targetApp then
      targetApp:activate()
    else
      hs.application.launchOrFocus(applicationName)
    end

    local app = hs.application.get(applicationName)
    if not app then
      hs.alert(string.format("Launching %s", applicationName))
    else
      local windows = app:allWindows()
      if windows then
        windows = hs.fnutils.filter(windows, hs.window.isStandard)
        windows = hs.fnutils.filter(windows, hs.window.isVisible)  

        if #windows > 1 then
          hs.alert.show(string.format("%s - %d", app:name(), #windows), 0.5)
        elseif #windows == 0 then 
          hs.alert.show(string.format("%s (no windows)", app:name()), 0.5)
        else
          hs.alert.show(string.format("%s", app:name()), 0.5)
        end
      
        if hs.window.focusedWindow() then
          hs.mouse.setAbsolutePosition( hs.window.focusedWindow():frame().center )
          mouseHighlight()
        end
      end
    end
end

return obj
