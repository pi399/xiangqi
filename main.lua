require("board")
require("piece")
require("layout")
require("starfield")

local board

local font
local font_size = 24
local stars = Starfield(2000)

local px, py, dx, dy, damping = 0, 0, 0, 0, .7
local mousePressed = false
local moveColor = "R"
local black,red = {0,0.1,0.18}, {0.15,0.1,0.1}

local function drawDebugLayout()
	for i = 1,10,1 do for j = 1,9,1 do
		love.graphics.print(board.layout[j][i].type or " ", 30*j, 30*i)
	end end
end

local function inBounds(x,y) return (x > 0) and (x < 10) and (y > 0) and (y < 11) end
local emptySpace = { type = false, character = false }

function love.load()
	font = love.graphics.newFont("NotoSansTC-Bold.ttf",font_size)
	love.graphics.setFont(font)
	--font:setFilter("nearest", "nearest", 0)
	
	board = Board()
	love.graphics.setPointSize(2)
end

function love.draw()
	love.graphics.setBackgroundColor(moveColor == "R" and red or black)
	stars:draw()
	board:draw()
end

local timer = 0
function love.update(dt)
	timer = timer + dt
	board.theta = 0.01 * math.sin(timer / 4)
	board.x = 100+math.cos(timer)
	stars:update(dt)
	board:update(dt)
	
	if mousePressed and board.activePiece then
		local x, y = love.mouse.getPosition()
		local x_vector, y_vector = (px - x), (py - y)
		dx, dy = (dx + x_vector) * damping, (dy + y_vector) * damping
		board.activePiece.x, board.activePiece.y = x + dx, y + dy
		px, py = x, y
	end
end

function love.keypressed(key)
	if key == 'f' then
		board:resize(board.scale+0.01)
	elseif key == 'r' then
		board:resize(board.scale-0.01)
	end
end

function love.mousepressed(x, y, button)
	mousePressed, px, py = true, x, y
	local i, j = board:nearestPosition(x, y)
	if board.layout[i][j].type and moveColor == board.layout[i][j].color then
		board.activePiece = board.layout[i][j]
		board.activePiece.x, board.activePiece.y = x, y
	end
end

function love.mousemoved(x, y, dx, dy)

end

function love.mousereleased(x, y, button)
	mousePressed = false
	if board.activePiece.type then
		local i, j = board:nearestPosition(x, y)
		if board.activePiece:canMove(i, j) then
			board.activePiece:move(i,j)
			board.activePiece = emptySpace
			moveColor = (moveColor == "R") and "B" or "R"
		else
			board.activePiece:update()
			board.activePiece = emptySpace
		end
	end
end


function love.resize(w,h)
	stars = Starfield(2000)
end