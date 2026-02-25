require("board")
require("piece")
require("layout")
require("starfield")
require("spring")

local bgm = love.audio.newSource("resources/audio/tendas.mp3", "stream") bgm:setVolume(0.6) bgm:setLooping(false)
local audioOn = true

local stars = Starfield(2000)
local black,red = {0.1,0.1,0.15}, {0.15,0.1,0.1}

local B
local inCheck = false

function love.load()
	love.graphics.setPointSize(2)
	B = Board()
	bgm:play()
end

function love.draw()
	love.graphics.setBackgroundColor(B.moveColor == "R" and red or black)
	stars:draw()
	B:draw()
	if inCheck then
		love.graphics.setColor(1,1,1)
		love.graphics.print((B.moveColor == "R" and "Red" or "Black") .. " is in check!", 40, love.graphics.getHeight() / 2)
	end
end

local timer = 0
function love.update(dt)
	timer = timer + dt
	B.theta = 0.01 * math.sin(timer / 3)		--slight board shake effect
	B.x = B.x + 0.05 * math.sin(timer / 2)
	stars:update(dt)
	B:update(dt)
	if audioOn and not bgm:isPlaying() then
		bgm:seek(17.454)
		bgm:play()
	end
end

function love.keypressed(key)
	if key == 'r' then
		B:loadLayout()
	elseif key == 'm' then
		audioOn = not audioOn
		if bgm:isPlaying() then
			bgm:stop()
		else
			bgm:play()
		end
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