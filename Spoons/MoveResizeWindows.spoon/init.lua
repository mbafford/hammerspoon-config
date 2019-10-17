local obj={}
obj.__index = obj
obj.name = "Move/Resize Windows"
obj.version = "0.1"
obj.author = "Matthew Bafford <matthew.bafford@gmail.com>"
obj.homepage = "https://github.com/mbafford/hammerspoon-config"
obj.license = "MIT - https://opensource.org/licenses/MIT"

-- find the window to resize, accounting for apps where there are no
-- windows HammerSpoon can find - those will return nil to indicate no
-- resize should happen
function getResizeWindow() 
  local focusedApp     = hs.application.frontmostApplication()
  if not focusedApp then
    hs.alert("Resize Window - no active app")
    return nil
  end
  local focusedWindow  = focusedApp:focusedWindow()
  if not focusedWindow then
    hs.alert(string.format("Resize Window - %s has no active windows", focusedApp:title()))
    return nil
  end

  return focusedWindow
end

function obj:init()
end

function obj:left50()
  local win = getResizeWindow()
  if not win then return end

  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end

function obj:right50()
  local win = getResizeWindow()
  if not win then return end

  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x + (max.w / 2)
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end

function obj:top50()
  local win = getResizeWindow()
  if not win then return end

  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w
  f.h = max.h / 2
  win:setFrame(f)
end

function obj:bottom50()
  local win = getResizeWindow()
  if not win then return end

  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y + (max.h / 2)
  f.w = max.w
  f.h = max.h / 2
  win:setFrame(f)
end

function obj:center75()
  local win = getResizeWindow()
  if not win then return end

  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x + (max.w / 8)
  f.y = max.y
  f.w = 6*( max.w / 8 )
  f.h = max.h
  win:setFrame(f)
end

function obj:fullScreen()
  local win = getResizeWindow()
  if not win then return end

  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w
  f.h = max.h
  win:setFrame(f)
end

-- move current window to the space sp
function obj:moveWindowToSpace(sp)
  local win = getResizeWindow()
  if not win then return end

  if sp > #hs.screen.allScreens() then
      hs.alert(string.format("No space %d available", sp))
      return
  end

  win:moveToScreen( hs.screen.allScreens()[sp] )
end

return obj
