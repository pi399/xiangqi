require("board")
require("piece")
require("layout")
require("starfield")

local font
local stars = Starfield(2000)
local black,red = {0,0.1,0.18}, {0.15,0.1,0.1}
local inCheck = false

local px, py, dx, dy, damping = 0, 0, 0, 0, .7
local mousePressed = false

local board
local moveColor = "R"

local function drawDebugLayout()
	for i = 1,9,1 do for j = 1,10,1 do
		love.graphics.print(board.layout[i][j].type or " ", 30*j, 30*i)
	end end
end

local emptySpace = { type = false, character = false }

function love.load()
	font = love.graphics.newFont("NotoSansTC-Regular.ttf",18)
	love.graphics.setFont(font)
	board = Board()
	love.graphics.setPointSize(2)
end

function love.draw()
	love.graphics.setBackgroundColor(moveColor == "R" and red or black)
	stars:draw()
	board:draw()
	love.graphics.setColor(1,1,1)
	love.graphics.print((moveColor == "R" and "Red" or "Black").. " is " .. (inCheck and "in check" or "moving"), 10, 10)
end

local timer = 0
function love.update(dt)
	timer = timer + dt
	board.theta = 0.01 * math.sin(timer / 3)		--slight board shake effect
	board.x = board.x + 0.05 * math.sin(timer / 2)
	stars:update(dt)
	board:update(dt)
	
	if mousePressed and board.activePiece then		--some physics to soften the piece moving with the mouse
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

function love.mousereleased(x, y, button)
	mousePressed = false
	if board.activePiece.type then
		local i, j = board:nearestPosition(x, y)
		if board.activePiece:move(i,j) then
			moveColor = (moveColor == "R") and "B" or "R" -- change active player
			inCheck = board:findChecks(moveColor)
		end
		board.activePiece:update()
		board.activePiece = emptySpace
	end
end


function love.resize(w,h)
	stars = Starfield(w * h * 0.005)
	board.x, board.y = w/2 - ( board.width + board.b * 2 ) / 2, h/2 - ( board.height + board.b * 2 ) / 2
	board:values()
end