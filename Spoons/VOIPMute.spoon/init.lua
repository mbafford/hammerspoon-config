local obj={}
obj.__index = obj
obj.name = "VOIP Mute"
obj.version = "0.1"
obj.author = "Matthew Bafford <matthew.bafford@gmail.com>"
obj.homepage = "https://github.com/mbafford/hammerspoon-config"
obj.license = "MIT - https://opensource.org/licenses/MIT"

function obj:init()
end

-- toggle the mute status of frequently used VOIP apps and bring the call window to the foreground
-- each app has their own own special way of accomplishing this
-- this could be done substantially more easily using something like:
--     hs.audiodevice.allInputDevices()[1]:setInputMuted(true)
-- but this has the downside of:
--     not indicating your muted status to the client / other participants
--     potentially having mute/unmute status out of sync
--     no obvious indicator
muteActiveVOIPClient = (function()
  muteVOIPAlerts = {}

  function voipAlert(s)
    table.insert(muteVOIPAlerts, hs.alert(s, 0.5))
  end

  function clearVoipAlerts()
    if #muteVOIPAlerts > 0 then
      for k,v in pairs(muteVOIPAlerts) do
        hs.alert.closeSpecific(v, 0)
      end
    end

    muteVOIPAlerts = {}
  end

  function parse_slack_call_title(title)
    return string.match(title, "^(Slack [|] .* [|] )[0-9]+:[0-9]+")
  end

  return function()
    clearVoipAlerts()

    local slack_running       = false
    local slack_in_call       = false
    local webex_running       = false
    local webex_in_call       = false
    local skype_running       = false
    local skype_maybe_in_call = false

    -- Slack is a bastard
    -- the windows don't have any titles that HammerSpoon can see, so you can't tell which one is the call window
    -- the app doesn't have a menu item for mute/unmute
    -- there doesn't appear to be any way to find out the current mute/unmute status
    -- (maybe there's a system API that lets you know if the microphone is being used?)
    -- there's no way to explicitly invoke a desired status - just toggle
    -- so use the Window menu to find the "Slack | Slack call..." menu item and toggle that, then send "m" to that menu
    ---
    -- the smaller call status window would be easy to find reliably using the size of the window, but it does not respond
    -- to the "m" key to toggle mute status
    local app_slack = hs.appfinder.appFromName('Slack')
    if app_slack then
      slack_running = true

      menu = app_slack:getMenuItems()
      windowmenu = nil
      for k,v in pairs(menu) do
        if v.AXTitle == "Window" then
          windowmenu = v
        end
      end

      slack_call_title = nil
      for k,v in pairs(windowmenu.AXChildren[1]) do
        slack_call_title = parse_slack_call_title( v.AXTitle )
        if slack_call_title then
          slack_in_call = true
          break
        end
      end

      -- the slack menu item changes every second as the call progresses
      -- so select using the regex
      if slack_in_call then
        app_slack:activate()
        local slack_search = string.format("%s.*", string.gsub(slack_call_title, "([^a-zA-Z0-9 ])", "\\%1"))
        local menu_found = app_slack:selectMenuItem(slack_search, true)
        voipAlert("VOIP Call - Slack - Sending Mute Toggle 🎤 / ⛔")
        hs.eventtap.keyStrokes("M")
      end
    end

    -- WebEx muting can be detected and controlled using the menu items Participant -> Mute Me / Unmute Me
    -- this works very well, even if the WebEx app isn't activated or the window isn't visible
    -- the only limitation I've found is that the menu items don't refresh their current status (either in the app,
    -- or from hammerspoon's perspective) for about 1 second after the state changes. So you can't quickly toggle
    -- back and forth between muted and unmuted (the subsequent attempts are no-op). That doesn't seem to matter in
    -- a practical sense
    local app_webex = hs.appfinder.appFromName('Cisco WebEx Meeting Center')
    if app_webex then
      webex_running = true
      local menu_unmute = app_webex:findMenuItem({"Participant", "Unmute Me"})

      if menu_unmute then
        webex_in_call = true      
        app_webex:activate()

        if menu_unmute.enabled then
          app_webex:selectMenuItem({"Participant", "Unmute Me"})
          voipAlert("VOIP Call - WebEx - UnMuted 🎤")
        else
          app_webex:selectMenuItem({"Participant", "Mute Me"})
          voipAlert("VOIP Call - WebEx - Muted ⛔")
        end
      end
    end

    -- Skype is even worse than Slack - there's no change in indicator that a call is happening, there's no
    -- menu item to look for, the window title doesn't change - nothing.
    -- The best I can figure out is to look for the Skype window existing, and sending the Cmd+Shift+M keystroke
    -- to it. Hopefully the mute shortcut will only be invoked when I know there's a VOIP call in progress, so this
    -- should be pretty safe - with the only negative side-effect being the Skype window popping up if I don't want it.
    -- It's possible to keep a call running only in the background with only the menubar icon showing - but I don't
    -- think I'll have that issue - so I'm going to use the existance of a Skype window (with the lack of any *known* VOIP
    -- call from another system) to be the criteria for falling back to Skype. I don't use Skype much, thankfully.
    local app_skype = hs.application.get('Skype')
    if app_skype then
      skype_running = true

      local skype_windows = app_skype:allWindows()

      if #skype_windows > 0 then
        if not webex_in_call and not slack_in_call then
          app_skype:activate()
          hs.eventtap.keyStroke({"cmd", "shift"}, "m")
          voipAlert("VOIP Call - Skype - Sending Mute Toggle 🎤 / ⛔")

          skype_maybe_in_call = true
        end
      end
    end

    if slack_in_call and webex_in_call then
      voipAlert("Multiple known VOIP Calls Running (Slack and Webex)")
    end

    if not slack_in_call and not webex_in_call and not skype_maybe_in_call then
      voipAlert("No VOIP Call Running (Slack/WebEx/Skype)")
    end

    --  voipAlert(string.format("Slack: Running: %s In Call: %s\nWebex: Running: %s In Call: %s", slack_running, slack_in_call, webex_running, webex_in_call))
  end
end)()


function obj:toggleMute()
    muteActiveVOIPClient()
end



return obj
