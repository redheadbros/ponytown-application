--[[

Programming test for ponytown application
General notes on how long this took:
-> had 5000 targets moving around and clickable at 50fps by 1h 45min
-> working timer by 2h 30min
-> end screen, feature-complete by 3h 15min

]]--


function love.load()
	--note: the random seed is the same every time.

	--global constants
	WINDOW_WIDTH = 800
	WINDOW_HEIGHT = 650

	TARGET_RADIUS = 10
	TARGET_SPEED = 50
	NUMBER_OF_TARGETS = 5000

	TIME_TO_PLAY = 60

	--setup
	setupGraphics()
	setupPhysics()

	--global variables
	gameStarted = false
	gameOver = false

	shots = 0
	hits = 0
end

function love.draw()
	for i=#physObjects,1,-1 do
		if physObjects[i].draw then
			love.graphics.draw(targetSprite,physObjects[i].body:getX() - TARGET_RADIUS,physObjects[i].body:getY() - TARGET_RADIUS)
		end
	end

	--draw fps counter
	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("fill",0,0,50,20)
	love.graphics.setColor(1,1,1)
	love.graphics.setFont(smallFont)
	love.graphics.print("fps: " .. love.timer.getFPS())

	--note: UI is hell, I need a better system for this. (children, parents etc)
	if gameStarted and not gameOver then 
		--display running countdown timer
	
		local timeSinceStart = love.timer.getTime() - startTime
		local timerValue = TIME_TO_PLAY - (timeSinceStart - (timeSinceStart % 1))

		local timerBoxWidth = 90
		local timerBoxHeight = 70
		local marginBelowBox = 20
		local cornerRadius = 10
		local cornerX,cornerY = WINDOW_WIDTH/2 - timerBoxWidth/2, WINDOW_HEIGHT - marginBelowBox - timerBoxHeight
		love.graphics.setColor(0,0,0)
		love.graphics.rectangle("fill",cornerX,cornerY,timerBoxWidth,timerBoxHeight,cornerRadius)
		love.graphics.setColor(1,1,1)
		love.graphics.rectangle("line",cornerX,cornerY,timerBoxWidth,timerBoxHeight,cornerRadius)
		
		local lineWidth = 60
		local textX = WINDOW_WIDTH/2 - lineWidth/2
		local textY = WINDOW_HEIGHT - marginBelowBox - timerBoxHeight/2 - bigFont:getHeight()/2
		love.graphics.setFont(bigFont)
		love.graphics.printf(timerValue,textX,textY,lineWidth,"center")
	elseif not gameStarted and not gameOver then
		--display "click to play" text box

		local timerBoxWidth = 300
		local timerBoxHeight = 70
		local marginBelowBox = 20
		local cornerRadius = 10
		local cornerX,cornerY = WINDOW_WIDTH/2 - timerBoxWidth/2, WINDOW_HEIGHT - marginBelowBox - timerBoxHeight
		love.graphics.setColor(0,0,0)
		love.graphics.rectangle("fill",cornerX,cornerY,timerBoxWidth,timerBoxHeight,cornerRadius)
		love.graphics.setColor(1,1,1)
		love.graphics.rectangle("line",cornerX,cornerY,timerBoxWidth,timerBoxHeight,cornerRadius)

		local lineWidth = 300
		local textX = WINDOW_WIDTH/2 - lineWidth/2
		local textY = WINDOW_HEIGHT - marginBelowBox - timerBoxHeight/2 - medFont:getHeight()/2
		love.graphics.setFont(medFont)
		love.graphics.printf("Click to start!",textX,textY,lineWidth,"center")
	elseif gameOver and gameStarted then
		--display ended timer and final stat screen

		local timerBoxWidth = 90
		local timerBoxHeight = 70
		local marginBelowBox = 20
		local cornerRadius = 10
		local cornerX,cornerY = WINDOW_WIDTH/2 - timerBoxWidth/2, WINDOW_HEIGHT - marginBelowBox - timerBoxHeight
		love.graphics.setColor(0,0,0)
		love.graphics.rectangle("fill",cornerX,cornerY,timerBoxWidth,timerBoxHeight,cornerRadius)
		love.graphics.setColor(1,1,1)
		love.graphics.rectangle("line",cornerX,cornerY,timerBoxWidth,timerBoxHeight,cornerRadius)
		
		local lineWidth = 60
		local textX = WINDOW_WIDTH/2 - lineWidth/2
		local textY = WINDOW_HEIGHT - marginBelowBox - timerBoxHeight/2 - bigFont:getHeight()/2
		love.graphics.setFont(bigFont)
		love.graphics.printf(0,textX,textY,lineWidth,"center")

		local winRectWidth = 500
		local winRectHeight = 300
		local winRectUpperMargin = 100
		local winRectCornerRadius = 20
		local winRectTopLeftX = WINDOW_WIDTH/2 - winRectWidth/2
		local winRectTopLeftY = winRectUpperMargin
		love.graphics.setColor(0,0,0)
		love.graphics.rectangle("fill",winRectTopLeftX,winRectTopLeftY,winRectWidth,winRectHeight,winRectCornerRadius)
		love.graphics.setColor(1,1,1)
		love.graphics.rectangle("line",winRectTopLeftX,winRectTopLeftY,winRectWidth,winRectHeight,winRectCornerRadius)

		local lineWidth = 500
		local winTextUpperMargin = 30
		local winTextX = winRectTopLeftX + winRectWidth/2 - lineWidth/2
		local winTextY = winRectTopLeftY + winTextUpperMargin
		love.graphics.setFont(bigFont)
		love.graphics.printf("You Win!!",winTextX,winTextY,lineWidth,"center")

		local lineWidth = 250
		local statTextUpperMargin = 20
		local statTextX = winRectTopLeftX + winRectWidth/2 - lineWidth/2
		local statTextY = winTextY + bigFont:getHeight() + statTextUpperMargin
		local statText = ""
		statText = statText .. "Shots: " .. shots .. "\n"
		statText = statText .. "Hits: " .. hits .. "\n"
		local hitPercent = hits/shots * 100 --lol, forgot to account for division by 0 here but I'm tired so oh well
		hitPercent = hitPercent - (hitPercent % 0.1)
		statText = statText .. "Hit %: " .. hitPercent .. "%\n"
		local missPercent = (shots - hits)/shots * 100
		missPercent = missPercent - (missPercent % 0.1)
		statText = statText .. "Miss %: " .. missPercent .. "%\n"
		love.graphics.setFont(medFont)
		love.graphics.printf(statText,statTextX,statTextY,lineWidth,"left")

	end
end

function love.update(dt)
	world:update(dt)

	--keep objects onscreen by wrapping around the edges
	for i=1,#physObjects do
		local x = physObjects[i].body:getX()
		local y = physObjects[i].body:getY()
		x = (x + TARGET_RADIUS) % (WINDOW_WIDTH + 2*TARGET_RADIUS) - TARGET_RADIUS
		y = (y + TARGET_RADIUS) % (WINDOW_HEIGHT + 2*TARGET_RADIUS) - TARGET_RADIUS
		physObjects[i].body:setX(x)
		physObjects[i].body:setY(y)
	end

	--game ending logic
	if gameStarted then
		local timeSinceStart = love.timer.getTime() - startTime
		if not gameOver and (timeSinceStart >= TIME_TO_PLAY) then
			gameOver = true
		end
	end
end

function love.mousepressed(x, y, button, istouch, presses)
	--shot logic
	if not gameOver then
		shots = shots + 1
		for i=1,#physObjects do
			local targetX, targetY = physObjects[i].body:getX(), physObjects[i].body:getY()
			local topLeftX, topLeftY, bottomRightX, bottomRightY = targetX - TARGET_RADIUS, targetY - TARGET_RADIUS, targetX + TARGET_RADIUS, targetY + TARGET_RADIUS
			if physObjects[i].draw and isPointInBox(x,y,topLeftX,topLeftY,bottomRightX,bottomRightY) then
				physObjects[i].draw = false
				hits = hits + 1
				break
			end
		end
	end
	--"click to start" logic
	if not gameStarted then
		gameStarted = true
		startTime = love.timer.getTime()
	end
end

--[[
	Does basic physics setup tasks: code was moved here to improve readablity in love.load().
]]--
function setupPhysics()
	love.physics.setMeter(64) 
	world = love.physics.newWorld(0, 0, true)
	physObjects = {}

	for i=1,NUMBER_OF_TARGETS do
		physObjects[i] = {}
		physObjects[i].draw = true
		physObjects[i].body = love.physics.newBody(world, math.random() * WINDOW_WIDTH,math.random() * WINDOW_HEIGHT, "dynamic")
		physObjects[i].shape = love.physics.newRectangleShape(TARGET_RADIUS*2,TARGET_RADIUS*2)
		physObjects[i].fixture = love.physics.newFixture(physObjects[i].body, physObjects[i].shape,1)
		physObjects[i].body:setFixedRotation(true)
		physObjects[i].fixture:setCategory(1)
		physObjects[i].fixture:setMask(1)
		local angle = math.random() * 2 * math.pi
		local velX = math.cos(angle) * TARGET_SPEED
		local velY = math.sin(angle) * TARGET_SPEED
		physObjects[i].body:setLinearVelocity(velX, velY)
	end
end

--[[
	Does basic graphics setup tasks: code was moved here to improve readablity in love.load().
]]--
function setupGraphics()
	local flags = {resizable=false}
	love.window.setMode(WINDOW_WIDTH,WINDOW_HEIGHT,flags)
	smallFont = love.graphics.newFont("Roboto_Mono/static/RobotoMono-Regular.ttf",11)
	medFont = love.graphics.newFont("Roboto_Mono/static/RobotoMono-Regular.ttf",30)
	bigFont = love.graphics.newFont("Roboto_Mono/static/RobotoMono-Regular.ttf",50)
	love.graphics.setFont(smallFont)

	--creates a single canvas that gets drawn from for each target, to reduce redundant draw calls.
	targetSprite = love.graphics.newCanvas(TARGET_RADIUS*2,TARGET_RADIUS*2)
	love.graphics.setCanvas(targetSprite)
	love.graphics.setColor(1,1,1)
	love.graphics.circle("fill",TARGET_RADIUS,TARGET_RADIUS,TARGET_RADIUS)
	love.graphics.setColor(0,0,0)
	love.graphics.circle("line",TARGET_RADIUS,TARGET_RADIUS,TARGET_RADIUS)
	love.graphics.setCanvas()
end

--returns true if the point (x,y) is in the rectangle with top left corner (topLeftX,topLeftY) and bottom right corner (bottomRightX,bottomRightY)
function isPointInBox(x,y,topLeftX,topLeftY,bottomRightX,bottomRightY)
	return (topLeftX <= x) and (x < bottomRightX) and (topLeftY <= y) and (y < bottomRightY)
end