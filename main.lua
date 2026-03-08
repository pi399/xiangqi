require("board")
require("piece")
require("layout")
require("starfield")
require("spring")
--local moonshine = require 'resources/shaders/moonshine'

local bgm = love.audio.newSource("resources/audio/tendas.mp3", "stream") bgm:setVolume(1) bgm:setLooping(false)
local nebula = love.graphics.newImage("resources/textures/photo/milky_way.jpg")
--local crt = moonshine(moonshine.effects.crt)

local stars = Starfield(2000)
local black,red = {0.2,0.2,0.34}, {0.34,0.2,0.2}

local inCheck = false
local B

function love.load()
	love.graphics.setPointSize(2)
	B = Board()
	--crt.x, crt.y = B.x, B.y
	bgm:play()
end

function love.draw()
	love.graphics.setBackgroundColor(B.moveColor == "R" and red or black)
	love.graphics.setColor(1,1,1,0.6)
	love.graphics.draw(nebula,-50,-50,-B.theta)
	stars:draw()
	B:draw()
	love.graphics.setColor(1,1,1)
	love.graphics.print(love.timer.getFPS(),20,20)
	if inCheck then
		love.graphics.setColor(1,1,1)
		love.graphics.print((B.moveColor == "R" and "Red" or "Black") .. " is in check!", 40, love.graphics.getHeight() / 2)
	end
end

local timer = 0
function love.update(dt)
	timer = timer + dt
	B.theta = 0.01 * math.sin(timer / 3)		--slight board shake effect / celery man
	B.x = B.x + 0.05 * math.sin(timer / 2)
	stars:update(dt)
	B:update(dt)
	if not bgm:isPlaying() then
		bgm:seek(17.454)
		bgm:play()
	end
end

function love.keypressed(key)
	if key == 'r' then
		B:loadLayout()
	elseif key == 'm' then
		bgm:setVolume(0)
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
	stars = Starfield(w * h * 0.005)
	B:center()
end