


local composer = require( "composer" )


display.setStatusBar( display.HiddenStatusBar ) 


if system.getInfo( "androidApiLevel" ) and system.getInfo( "androidApiLevel" ) < 19 then
	native.setProperty( "androidSystemUiVisibility", "lowProfile" )
else
	native.setProperty( "androidSystemUiVisibility", "immersiveSticky" ) 
end


local isSimulator = "simulator" == system.getInfo( "environment" )
local isMobile = ( "ios" == system.getInfo("platform") ) or ( "android" == system.getInfo("platform") )


if isSimulator then 

	
	local visualMonitor = require( "com.ponywolf.visualMonitor" )
	local visMon = visualMonitor:new()
	visMon.isVisible = false

	local function debugKeys( event )
		local phase = event.phase
		local key = event.keyName
		if phase == "up" then
			if key == "f" then
				visMon.isVisible = not visMon.isVisible 
			end
		end
	end
	
	Runtime:addEventListener( "key", debugKeys )
end


require( "com.ponywolf.joykey" ).start()


system.activate("multitouch")



audio.reserveChannels(1)


composer.gotoScene( "scene.menu", { params={ } } )


