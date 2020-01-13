-- simplify launching and cycling to the windows for a specific Chrome Persona
local obj={}
obj.__index = obj
obj.name = "Chrome Persona Selector"
obj.version = "0.1"
obj.author = "Matthew Bafford <matthew.bafford@gmail.com>"
obj.homepage = "https://github.com/mbafford/hammerspoon-config"
obj.license = "MIT - https://opensource.org/licenses/MIT"

function obj:init()
end

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


function obj:selectPersona(persona)
	local app_chrome = hs.appfinder.appFromName('Google Chrome')
	if not app_chrome then
		hs.alert("Unable to find Google Chrome", 0.5)
		return
	end

	app_chrome:selectMenuItem({"People", persona})
	hs.alert(string.format("Google Chrome - %s", persona))

    if hs.window.focusedWindow() then
      hs.mouse.setAbsolutePosition( hs.window.focusedWindow():frame().center )
      mouseHighlight()
    end
end

return obj