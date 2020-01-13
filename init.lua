-- absolutely essential to change animation to 0, or every window move/resize just feels painful
hs.window.animationDuration = 0

invoke_keys  = {"cmd", "shift",         "alt"}
super_invoke = {"cmd", "shift", "ctrl", "alt"}

-- allow for quick reloading hammerspoon config
hs.hotkey.bind(super_invoke, "R", function() 
  hs.reload()
end)

hs.hotkey.bind(super_invoke, 'h', function()
  hs.openConsole()
  -- hs.consoleOnTop( true )
end)

log = hs.logger.new("mbafford", "debug")

hs.loadSpoon("AppLaunchOrCycle")
hs.loadSpoon("ChromePersona")

-- hs.hotkey.bind(invoke_keys, 'g', function() spoon.AppLaunchOrCycle:launchOrCycleFocus('Google Chrome'             ) end )
hs.hotkey.bind(invoke_keys, 'g', function() spoon.ChromePersona:selectPersona('Matthew (Matthew (Personal))') end )
hs.hotkey.bind(invoke_keys, 'a', function() spoon.ChromePersona:selectPersona('Matthew (Matthew (Work))') end )

hs.hotkey.bind(invoke_keys, 'x', function() spoon.AppLaunchOrCycle:launchOrCycleFocus('Firefox'                   ) end )
hs.hotkey.bind(invoke_keys, 'v', function() spoon.AppLaunchOrCycle:launchOrCycleFocus('Code'                      ) end )
hs.hotkey.bind(invoke_keys, 'i', function() spoon.AppLaunchOrCycle:launchOrCycleFocus('iTerm2'                    ) end )
hs.hotkey.bind(invoke_keys, 'n', function() spoon.AppLaunchOrCycle:launchOrCycleFocus('Notes'                     ) end )
hs.hotkey.bind(invoke_keys, 't', function() spoon.AppLaunchOrCycle:launchOrCycleFocus('Telegram'                  ) end )
hs.hotkey.bind(invoke_keys, 's', function() spoon.AppLaunchOrCycle:launchOrCycleFocus('Slack'                     ) end )
hs.hotkey.bind(invoke_keys, 'e', function() spoon.AppLaunchOrCycle:launchOrCycleFocus('Eclipse'                   ) end )
hs.hotkey.bind(invoke_keys, 'w', function() spoon.AppLaunchOrCycle:launchOrCycleFocus('Cisco WebEx Meeting Center') end )
hs.hotkey.bind(invoke_keys, 'q', function() spoon.AppLaunchOrCycle:launchOrCycleFocus('SQLWorkbenchJ'             ) end )

hs.loadSpoon("VOIPMute")
hs.hotkey.bind(invoke_keys, 'm', spoon.VOIPMute.toggleMute)

hs.loadSpoon("MoveResizeWindows")
hs.hotkey.bind(invoke_keys, "Left",  function() spoon.MoveResizeWindows:left50    () end) 
hs.hotkey.bind(invoke_keys, "Right", function() spoon.MoveResizeWindows:right50   () end)
hs.hotkey.bind(invoke_keys, "Up",    function() spoon.MoveResizeWindows:top50     () end)
hs.hotkey.bind(invoke_keys, "Down",  function() spoon.MoveResizeWindows:bottom50  () end)
hs.hotkey.bind(invoke_keys, "C",     function() spoon.MoveResizeWindows:center75  () end)
hs.hotkey.bind(invoke_keys, "F",     function() spoon.MoveResizeWindows:fullScreen() end)
hs.hotkey.bind(invoke_keys, '1',     function() spoon.MoveResizeWindows:moveWindowToSpace(1) end)
hs.hotkey.bind(invoke_keys, '2',     function() spoon.MoveResizeWindows:moveWindowToSpace(2) end)

hs.hotkey.bind(invoke_keys, 'z', function()
  local seconds = 3
  local message = os.date("%I:%M%p") .. "\n" .. os.date("%a %b %d") .. "\nBattery: " ..  hs.battery.percentage() .. "%"
  hs.alert.show(message, seconds)
end)

function muteOnWake(eventType)
  if ( eventType == hs.caffeinate.watcher.systemDidWake ) then
    local output = hs.audiodevice.defaultOutputDevice()
    output:setMuted(true)
  end
end
caffeinateWatcher = hs.caffeinate.watcher.new(muteOnWake)
caffeinateWatcher:start()

hs.alert("HammerSpoon Configuration Reloaded", 0.5)

