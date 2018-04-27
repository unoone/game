

local composer = require( "composer" )
local fx = require( "com.ponywolf.ponyfx" )
local tiled = require( "com.ponywolf.ponytiled" )
local json = require( "json" )
local starFieldGenerator = require("scene.menu.lib.starfieldgenerator") 

local ui, bgMusic, start, exit


local scene = composer.newScene() 

local function key(event)
	
	if event.phase == "up" and event.keyName == "escape" then
		if not (composer.getSceneName("current") == "scene.menu") then
			fx.fadeOut(function ()
					composer.gotoScene("scene.menu")
				end)
		end
	end
end


function scene:create( event )

	local sceneGroup = self.view 
    local starGenerator = starFieldGenerator.new(75,sceneGroup,5)
	
	

	
	local uiData = json.decodeFile( system.pathForFile( "scene/menu/ui/title.json", system.ResourceDirectory ) )
	ui = tiled.new( uiData, "scene/menu/ui" )

	
	start = display.newImage("scene/menu/img/new_game_btn.png",display.contentCenterX,display.contentCenterY+100)
	function start:tap()
		fx.fadeOut( function()
				composer.gotoScene( "scene.game", { params = {} } )
			end )
	end
	fx.breath( start )

   
    local logo = display.newImageRect("scene/menu/img/logo.png",display.contentWidth/2,display.contentHeight/2)
    logo.x = display.contentCenterX --центрирование по горизонтали
    logo.y = display.contentCenterY - 200
	

	sceneGroup:insert( ui )
	sceneGroup:insert (logo)
	sceneGroup: insert(start)
	
	Runtime:addEventListener("key", key)
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
		start:addEventListener( "tap" )
		
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
	audio.dispose( bgMusic )  
	Runtime:removeEventListener("key", key)
end

scene:addEventListener( "create" )
scene:addEventListener( "show" )
scene:addEventListener( "hide" )
scene:addEventListener( "destroy" )

return scene