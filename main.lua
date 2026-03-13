require("board")
require("piece")
require("starfield")
require("button")

local stars = Starfield()
local black,red = {0.8,0.8,0.9},{0.96,0.8,0.8}

local inCheck = false
local B

local bgm = love.audio.newSource("resources/audio/tendas.mp3", "stream") bgm:setLooping(false)
local startupSound = love.audio.newSource("resources/audio/good music.mp3", "static")

local UI = {
	xiangqiPlay = Button:new(100, 500, "play xiangqi"),
	blankPlay = Button:new(320, 500, "blank pieces"),
	quit = Button:new(540, 500, "quit")
}

function love.load()
	bgm:play()
end

function love.draw()
	if B then
		love.graphics.setColor(B.moveColor == "R" and red or black)
	else
		love.graphics.setColor(0.8,0.8,0.8)
	end
	stars:draw()
	if B then B:draw() end
	if inCheck then
		love.graphics.setColor(1,1,1)
		love.graphics.print((B.moveColor == "R" and "Red" or "Black") .. " is in check!", 40, love.graphics.getHeight() / 2)
	end
	for k,v in pairs(UI) do v:draw() end
end

function love.update(dt)
	stars:update(dt)
	if B then
		local timer = love.timer.getTime()
		B.theta = 0.01 * math.sin(timer / 3)
		B.x = B.x + 0.05 * math.sin(timer / 2)
		B:update(dt)
	end
	if not bgm:isPlaying() and not startupSound:isPlaying() then bgm:seek(17.5) bgm:play() end
end

function love.keypressed(key)
	if key == 'r' and B then
		B:loadLayout()
	elseif key == 'm' then
		bgm:setVolume(bgm:getVolume() == 1 and 0 or 1)
	elseif key == 'q' then
		for k,v in pairs(UI) do
			v.visible = true
		end
		B = nil
	end
end

function love.mousepressed(x, y, button)
	if B then B:mousePressed(x,y,button) end
	for k,v in pairs(UI) do
		v:mousePressed(x,y)
	end
end

function love.mousereleased(x, y, button)
	if B then
		B:mouseReleased(x,y,button)
		inCheck = B:findChecks(B.moveColor)
	end
	for k,v in pairs(UI) do
		local value = v:mouseReleased(x,y)
		if value then
			for k,v in pairs(UI) do
				v.visible = false
			end
			B = value
			startupSound:play()
			bgm:pause()
		end
	end
end

function love.resize(w,h)
	if w < h * .9 then
		local _, _2, flags = love.window.getMode()
		love.window.setMode(h * .91, h, flags)
	end
	stars:resize(w,h)
	if B then B:center() end
end