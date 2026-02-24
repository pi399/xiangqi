require("board")
require("piece")
require("layout")
require("starfield")
require("spring")

local font
local stars = Starfield(2000)
local black,red = {0,0.1,0.18}, {0.15,0.1,0.1}

local board
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
	love.graphics.setBackgroundColor(board.moveColor == "R" and red or black)
	stars:draw()
	board:draw()
	if inCheck then
		love.graphics.setColor(1,1,1)
		love.graphics.print((board.moveColor == "R" and "Red" or "Black") .. " is in check!", 40, love.graphics.getHeight() / 2)
	end
end

local timer = 0
function love.update(dt)
	timer = timer + dt
	board.theta = 0.01 * math.sin(timer / 3)		--slight board shake effect
	board.x = board.x + 0.05 * math.sin(timer / 2)
	stars:update(dt)
	board:update(dt)
end

function love.keypressed(key)

end

function love.mousepressed(x, y, button)
	board:mousePressed(x,y,button)
end

function love.mousereleased(x, y, button)
	board:mouseReleased(x,y,button)
	inCheck = board:findChecks(board.moveColor)
end

function love.resize(w,h)
	stars = Starfield(w * h * 0.005)
	board.x, board.y = w/2 - ( board.width + board.b * 2 ) / 2, h/2 - ( board.height + board.b * 2 ) / 2
	if board.activePiece.type then board.activePiece:update() end
end