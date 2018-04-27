local composer = require( "composer" )
local fx = require( "com.ponywolf.ponyfx" )
local tiled = require( "com.ponywolf.ponytiled" )
local json = require( "json" )


local ui, start


local scene = composer.newScene() 




function scene:create( event )

--

	local sceneGroup = self.view 
  
    local soundsDir = "scene/game/sfx/"
	scene.sounds = {
		main = audio.loadSound( soundsDir .. "mainTheme.mp3" ),
    }
    
    
    physics.start()
    physics.setGravity( 0, 32 )
    
    local filename = event.params.map or "scene/game/map/sandbox.json"
	local mapData = json.decodeFile( system.pathForFile( filename, system.ResourceDirectory ) )
    map = tiled.new( mapData, "scene/game/map" )
    
    
	map.extensions = "scene.game.lib."
	map:extend( "hero" )
    hero = map:findObject( "hero" )
    hero.filename = filename
end

local function enterFrame( event )

	local elapsed = event.time

end


function scene:show( event )

	local phase = event.phase
	if ( phase == "will" ) then
		fx.fadeIn()
	
		Runtime:addEventListener( "enterFrame", enterFrame )
	elseif ( phase == "did" ) then
		
		
            audio.play( self.sounds.main, { loops = -1, fadein = 750, channel = 15 } )
			
	end
end


function scene:hide( event )

	local phase = event.phase
	if ( phase == "will" ) then
		start:removeEventListener( "tap" )
		audio.fadeOut( { channel = 1, time = 1500 } )
	elseif ( phase == "did" ) then
		Runtime:removeEventListener( "enterFrame", enterFrame )
	end
end


function scene:destroy( event )
	audio.stop()  
	 
	Runtime:removeEventListener("key", key)
end

scene:addEventListener( "create" )
scene:addEventListener( "show" )
scene:addEventListener( "hide" )
scene:addEventListener( "destroy" )

return scene