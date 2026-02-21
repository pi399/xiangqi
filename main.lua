require("board_with_canvas")
require("piece")
require("layout")
require("starfield")

local board

local font
local font_size = 24
local i,j = 1, 1
local active = 1
local fg_stars = Starfield(2000)
local mouse_pressed = false

local function drawDebugLayout()
	for i = 1,10,1 do
		for j = 1,9,1 do
			love.graphics.print(tostring(board.layout[j][i].type), 30*j, 30*i)
		end
	end
end

local function inBounds(x,y) return (x > 0) and (x < 10) and (y > 0) and (y < 11) end

function love.load()

	love.graphics.setBackgroundColor(0.1,0.1,0.1)
	font = love.graphics.newFont("NotoSansTC-Bold.ttf",font_size)
	love.graphics.setFont(font)
	font:setFilter("nearest", "nearest", 0)

	board = Board()
	i,j = board.pieces[1]:position()
	
	love.graphics.setPointSize(2)
end

function love.draw()
	fg_stars:draw()
	love.graphics.print(love.timer.getFPS(), 10, 10)
	board:draw()
end

local timer = 0
function love.update(dt)
	timer = timer + dt
	board.theta = 0.01 * math.sin(timer)
	board.x = 100+math.cos(timer)
	board:update(dt)
	fg_stars:update(dt)
end

function love.keypressed(key)
	if key == 'w' then
		if inBounds(i,j - 1) then j = j - 1 end
	elseif key == 's' then
		if inBounds(i,j + 1) then j = j + 1 end
	elseif key == 'd' then
		if inBounds(i + 1,j) then i = i + 1 end
	elseif key == 'a' then
		if inBounds(i - 1,j) then i = i - 1 end
	elseif key == 'f' then
		board:resize(board.scale+0.01)
	elseif key == 'r' then
		board:resize(board.scale-0.01)
	elseif key == 'x' then
		active = active + 1
		if active > 32 then active = 32 end
		i,j = board.pieces[active].row, board.pieces[active].column
		return
	elseif key == 'c' then
		active = active - 1
		if active < 1 then active = 1 end
		i,j = board.pieces[active].row, board.pieces[active].column
		return
	end
	board.pieces[active]:move(i,j)

end

function love.mousepressed(x, y, button)
	mouse_pressed = true
	--board.pieces[active]:move(x,y)
end

function love.mousemoved(x, y, dx, dy)
	--if mouse_pressed then board.pieces[active]:move(x,y) end
end

function love.mousereleased(x, y, button) end
	mouse_pressed = false
end
