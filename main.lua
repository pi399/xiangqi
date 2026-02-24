require("board")
require("piece")
require("layout")
require("starfield")
require("spring")

local font
local stars = Starfield(2000)
local black,red = {0,0.1,0.18}, {0.15,0.1,0.1}

local mousePressed = false
local springs = { X = Spring(500,20,0), Y = Spring(500,20,0) }

local board
local moveColor = "R"
local inCheck = false

local function drawDebugLayout()
	for i = 1,9,1 do for j = 1,10,1 do
		love.graphics.print(board.layout[i][j].type or " ", 30*j, 30*i)
	end end
end

local emptySpace = { type = false, character = false }

function love.load()
	font = love.graphics.newFont("NotoSansTC-Regular.ttf",18)
	love.graphics.setFont(font)
	love.graphics.setPointSize(2)
	board = Board()
end

function love.draw()
	love.graphics.setBackgroundColor(moveColor == "R" and red or black)
	stars:draw()
	board:draw()
	if inCheck then
		love.graphics.setColor(1,1,1)
		love.graphics.print((moveColor == "R" and "Red" or "Black") .. " is in check!", 10, 10)
	end
end

local timer = 0
function love.update(dt)
	timer = timer + dt
	board.theta = 0.01 * math.sin(timer / 3)		--slight board shake effect
	board.x = board.x + 0.05 * math.sin(timer / 2)
	stars:update(dt)
	board:update(dt)
	springs.X:tick(dt)
	springs.Y:tick(dt)
	
	if mousePressed and board.activePiece then
		board.activePiece.x, board.activePiece.y = springs.X.position, springs.Y.position
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
	if moveColor == board.layout[i][j].color then
		board.activePiece = board.layout[i][j]
		board.activePiece.x, board.activePiece.y = x, y
		springs.X.position, springs.Y.position = x,y
		springs.X.target, springs.Y.target = x,y
	end
end

function love.mousemoved(x,y,dx,dy)
	if board.activePiece.type then
		springs.X.target, springs.Y.target = x, y
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
		board.activePiece = emptySpace
	end
end


function love.resize(w,h)
	stars = Starfield(w * h * 0.005)
	board.x, board.y = w/2 - ( board.width + board.b * 2 ) / 2, h/2 - ( board.height + board.b * 2 ) / 2
	board:values()
end