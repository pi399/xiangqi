require("board")
require("piece")
require("layout")
require("starfield")

local bgm = love.audio.newSource("resources/audio/tendas.mp3", "stream") bgm:setLooping(false)
local nebula = love.graphics.newImage("resources/textures/photo/milky_way.jpg")

local stars = Starfield()
local black,red = {0.8,0.8,0.9},{0.96,0.8,0.8}

local inCheck = false
local B

function love.load()
	B = Board()
	bgm:play()
end

function love.draw()
	love.graphics.setColor(B.moveColor == "R" and red or black)
	love.graphics.draw(nebula,0,0)
	stars:draw()
	B:draw()
	if inCheck then
		love.graphics.setColor(1,1,1)
		love.graphics.print((B.moveColor == "R" and "Red" or "Black") .. " is in check!", 40, love.graphics.getHeight() / 2)
	end
end

function love.update(dt)
	local timer = love.timer.getTime()
	
	--slight board shake / celery man
	B.theta = 0.01 * math.sin(timer / 3)
	B.x = B.x + 0.05 * math.sin(timer / 2)
	
	stars:update(dt)
	B:update(dt)
	
	--loop the song back to after the intro
	if not bgm:isPlaying() then bgm:seek(17.5) bgm:play() end
end

function love.keypressed(key)
	if key == 'r' then
		B:loadLayout()
	elseif key == 'm' then
		bgm:setVolume(bgm:getVolume() == 1 and 0 or 1)
	elseif key == 'y' then
		B.x, B.y = love.mouse.getPosition()
	end
end

function love.mousepressed(x, y, button)
	B:mousePressed(x,y,button)
end

function love.mousereleased(x, y, button)
	B:mouseReleased(x,y,button)
	inCheck = B:findChecks(B.moveColor)
end

function love.resize(w,h)
	stars = Starfield(w * h * 0.001)
	B:center()
end