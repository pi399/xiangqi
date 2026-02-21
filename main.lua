require("board_with_canvas")
require("piece")
require("layout")
require("starfield")

local board

local font
local font_size = 24
local fg_stars = Starfield(2000)
local mouse_pressed, mouse_x, mouse_y = false, 0, 0
local clicked_piece = false

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
	--board:update(dt)
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
	end
end

function love.mousepressed(x, y, button)
	mouse_pressed, mouse_x, mouse_y = true, x, y
	local i, j = board:nearestPosition(mouse_x, mouse_y)
	if board.layout[i][j].type then
		clicked_piece = board.layout[i][j]
		clicked_piece.x, clicked_piece.y = board:getCoordinates(i, j)
	end
end

function love.mousemoved(x, y, dx, dy)
	if mouse_pressed and clicked_piece then
		mouse_x, mouse_y = x, y
		local i, j = board:nearestPosition(mouse_x, mouse_y)
		clicked_piece.x, clicked_piece.y = board:getCoordinates(i, j)
	end
end

function love.mousereleased(x, y, button)
	mouse_pressed = false
	if clicked_piece then
		local i, j = board:nearestPosition(mouse_x, mouse_y)
		clicked_piece:move(i,j)
		clicked_piece = false
	end
end