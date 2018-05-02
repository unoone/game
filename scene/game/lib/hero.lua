

local fx = require( "com.ponywolf.ponyfx" )
local composer = require( "composer" )

--объявление модуля
local M = {}

function M.new( instance, options )
	ladderX = 0 --координаты лестницы по X
	ladderY = 0 
	local scene = composer.getScene( composer.getSceneName( "current" ) )
	local sounds = scene.sounds


	--Если это симультор или мобильный телефон, то показывать кнопки на экране
	local isSimulator = "simulator" == system.getInfo( "environment" )
    local isMobile = ( "ios" == system.getInfo("platform") ) or ( "android" == system.getInfo("platform") )
	if isMobile or isSimulator then
		local vjoy = require( "com.ponywolf.vjoy" )
		local buttonLeft = vjoy.newButton(64,"buttonB","left")
		buttonLeft.x, buttonLeft.y = 110, display.contentHeight - 128
		local buttonRight = vjoy.newButton(64,"buttonC")
		buttonRight.x, buttonRight.y = 250, display.contentHeight - 128
		local button = vjoy.newButton()
		button.x, button.y = display.contentWidth - 128, display.contentHeight - 128
	end
	
	options = options or {}

	
	instance.isVisible = false
	local parent = instance.parent
	local x, y = instance.x, instance.y

   
    
    local kirill_info = { width = 192, height = 263, numFrames = 12, sheetContentWidth = 2304, sheetContentHeight = 263 }
    local kirill_sheet = graphics.newImageSheet("scene/game/img/sprites.png",kirill_info)
    
    local kirill_data = {
        {
            name = "idle",
            frames = {9,10},
            time = 1000,
            loopCount = 0,
        },
        { name = "walk", frames = { 1,2,3,4,5,6,7 }, time = 450, loopCount = 0 },
		{ name = "jump", frames = { 8 } },
		{ name = "ouch", frames = { 8 } },
		{ name = "climb", frames = {11,12},time = 700, loopCount = 0}
    }
    
 
    
	instance = display.newSprite( parent, kirill_sheet, kirill_data )
	instance.x,instance.y = x, y
    instance:setSequence( "idle" )
    instance:play()

	-- добавление физики
	physics.addBody( instance, "dynamic", { radius = 54, density = 3, bounce = 0, friction =  6 } )
	instance.isFixedRotation = true
	instance.anchorY = 0.77

	
	

	--клавиатура
	local max, acceleration, left, right, flip,up = 375, 5000, 0, 0, 0,0
	local lastEvent = {}
	local function key( event )
	-- 	if isMobile then
	-- 	local phase = event.phase
	-- 	local name = event.keyName
	-- 	if ( phase == lastEvent.phase ) and ( name == lastEvent.keyName ) then return false end  -- Filter repeating keys
	   
	-- 	if phase == "down" then --клавиша нажата
            
            
	-- 		if  "buttonC" == name then
	-- 			right = acceleration
    --             flip = 100000
	-- 		end

	-- 			if  "buttonB" == name then
	-- 				left = -acceleration
	-- 				flip = -100000
	-- 			end

	-- 		if "buttonA" == name  then
	-- 			instance:jump()
			
    --         end

	-- 		if not ( left == 0 and right == 0 ) and not instance.jumping then
	-- 			instance:setSequence( "walk" )
	-- 			instance:play()
	-- 		end
            
            
	-- 	elseif phase == "up" then --клавиша отпущена
	-- 		if "buttonB" == name then left = 0 end
	-- 		if "buttonC" == name then right = 0 end
	-- 		if left == 0 and right == 0 and not instance.jumping then
    --             instance:setSequence("idle")
    --             instance:play()
	-- 		end
	-- 	end
	-- 	lastEvent = event
	-- end
	--if not isMobile  then 
		local phase = event.phase
		local name = event.keyName
		if ( phase == lastEvent.phase ) and ( name == lastEvent.keyName ) then return false end  -- Filter repeating keys
		if phase == "down" then
			if "left" == name or "a" == name then
				left = -acceleration
				flip = -100000
				print("left", left)
				
			end
			if "right" == name or "d" == name then
				right = acceleration
				flip = 100000
				
			elseif "space" == name then
				instance:jump()
			end
			if not ( left == 0 and right == 0 ) and not instance.jumping then
				instance:setSequence( "walk" )
				instance:play()
			end
		elseif phase == "up" then
			
			if "left" == name or "a" == name then left = 0 end
			if "right" == name or "d" == name then right = 0 end
			if left == 0 and right == 0 and not instance.jumping then
				instance:setSequence("idle")
				instance:play()
			end
		end
		lastEvent = event
	--end
	end

	function instance:jump()
		if not self.jumping then
			self:applyLinearImpulse( 0, -550 )
			self:setSequence( "jump" )
            self.jumping = true
        end
	end

	function instance:hurt()
		fx.flash( self )
		audio.play( sounds.hurt[math.random(2)] )
		if self.shield:damage() <= 0 then
			-- We died
			fx.fadeOut( function()
				composer.gotoScene( "scene.refresh", { params = { map = self.filename } } )
			end, 1500, 1000 )
			instance.isDead = true
			instance.isSensor = true
			self:applyLinearImpulse( 0, -500 )
			-- Death animation
			instance:setSequence( "ouch" )
			self.xScale = 1
			transition.to( self, { xScale = -1, time = 750, transition = easing.continuousLoop, iterations = -1 } )
			-- Remove all listeners
			self:finalize()
		end
	end


	function instance:collision( event )
		
		
		local phase = event.phase
		local other = event.other
		print(other.type)
		local y1, y2 = self.y + 50, other.y - ( other.type == "enemy" and 25 or other.height/2 )
		
		local vx, vy = self:getLinearVelocity()
		-- print("vx",vx)
		-- print("vy",vy)
		if phase == "began" then --начало столкновения
			if not self.isDead and ( other.type == "blob" or other.type == "enemy" ) then
				if y1 < y2 then
					-- Hopped on top of an enemy
					other:die()
				elseif not other.isDead then
					-- They attacked us
					self:hurt()
				end
			
			elseif other.type == "ladder" then
				print("yes")
				
				
				print(other.x)
				print(other.y)
				ladderX = other.x
				
				print(instance.x)
				print(instance.y)
				
				local function key1( event )
					local phase = event.phase
					local name = event.keyName
					print(name)
					
					if phase == "down" and other.type == "ladder" then
						if "up" == name or "w" == name then
							print("up")
							print(up)
							up = 1
							print(up)
							if(up == 1  and (instance.x > ladderX-20 and instance.x < ladderX+20)) then 
								instance:setSequence( "climb" )
								instance:play()
							end
						end
					end
					if phase == "up" then
						if "up" == name or "w" == name then
							
							print("up")
							print(up)
							up = 0
							print(up)
							
							
							
						end
					end
					
				end
				
				
				Runtime:addEventListener( "key", key1 )--отслеживание нажатий на клавиатуру
			
			elseif self.jumping and vy > 0 and not self.isDead then
				-- Landed after jumping
				self.jumping = false
				if not ( left == 0 and right == 0 ) and not instance.jumping then
					instance:setSequence( "walk" )
					instance:play()
				else
                    self:setSequence( "idle" )
                    self:play()
				end
			end
			
		end
		
	end

	function instance:preCollision( event )
		local other = event.other
		local y1, y2 = self.y + 50, other.y - other.height/2
		if event.contact and ( y1 > y2 ) then
			-- Don't bump into one way platforms
			if other.floating then
				event.contact.isEnabled = false
			else
				event.contact.friction = 0.1
			end
		end
	end


	--отвечает за перемещение
	local function enterFrame()
		-- Do this every frame
		local vx, vy = instance:getLinearVelocity()
		
		local dx = left + right -- 5000 или -5000
		if instance.jumping then dx = dx / 4 end
		if ( dx < 0 and vx > -max ) or ( dx > 0 and vx < max ) then
			
			instance:applyForce( dx or 0, 0, instance.x, instance.y ) --крч логика такая, вместо того чтобы двигать героя по x, ему задается сила притяжения по x которая двигает его. Положительная сила дивгает вправо по x отрицательная влево по x 
		end
		
		if(up == 1  and (instance.x > ladderX-20 and instance.x < ladderX+20)) then 
			instance:applyForce( 0, -1200, instance.x, instance.y )
		end
		

		-- Turn around
		instance.xScale = math.min( 1, math.max( instance.xScale + flip, -1 ) )
	end

	function instance:finalize()
		-- On remove, cleanup instance, or call directly for non-visual
		instance:removeEventListener( "preCollision" )
		instance:removeEventListener( "collision" )
		Runtime:removeEventListener( "enterFrame", enterFrame )
		Runtime:removeEventListener( "key", key )
	end

	-- Add a finalize listener (for display objects only, comment out for non-visual)
	instance:addEventListener( "finalize" )

	-- Add our enterFrame listener
	Runtime:addEventListener( "enterFrame", enterFrame )

	-- Add our key/joystick listeners
	Runtime:addEventListener( "key", key )
	
	-- Add our collision listeners
	instance:addEventListener( "preCollision" )
	instance:addEventListener( "collision" )
	

	--Return instance
	instance.name = "hero"
	instance.type = "hero"
	return instance
end

return M
