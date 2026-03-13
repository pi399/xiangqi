require("piece")
local layouts = require "layout"

local emptySpace = { type = false, character = false }
local function ord(i) return string.char(string.byte("a")+i-1) end
local function round(x,y)
	if x < 1 then x = 1
	elseif x > 9 then x = 9 end
	if y < 1 then y = 1
	elseif y > 10 then y = 10 end
	return x,y
end

--	board used to be drawn darker with color {0.8, 0.8, 0.5}
local rainbow = love.graphics.newShader("resources/shaders/rainbow.fs")
local image = love.graphics.newImage("resources/textures/2x/board.png")
image:setFilter("nearest","nearest")

local timer = 0
local flipped = false

function Board(kind)
	
	local b =
	{	b,sqDim, x, y, scale,
		baseDim			= 60,
		theta			= 0,
		kingPositions	= layouts[kind].kingPositions,
		moveColor		= "R",
		image			= image }
	
	function b:center(sc)
		local w,h			= love.graphics.getDimensions()
		self.scale			= sc or h / 800
		self.sqDim			= self.baseDim * self.scale
		self.b				= self.baseDim * self.scale * 1.334
		self.x				= w/2 - ( self.sqDim * 8 + self.b * 2 ) / 2
		self.y				= h/2 - ( self.sqDim * 9 + self.b * 2 ) / 2
		if self.layout then
			for j,row in ipairs(self.layout) do
        		for i,piece in ipairs(row) do
        			if piece.type then
        				piece:reset(self:getCoordinates(piece.row, piece.column))
        			end
        		end
        	end
		end
	end
	
	b:center()

	function b:draw()
		love.graphics.push()
		love.graphics.rotate(self.theta)
		love.graphics.setColor(1,1,1)
		love.graphics.draw(self.image,self.x,self.y,0,self.scale,self.scale)
		--draw pieces, except for the selected piece
		love.graphics.setColor(1,1,1)
		for j,row in ipairs(self.layout) do
        	for i,piece in ipairs(row) do
        		if piece.type and piece ~= self.activePiece then
        			piece:draw()
        		end
        	end
        end
        love.graphics.pop()
        
       	--draw selected piece last
		if self.activePiece.type then
			love.graphics.setShader(rainbow)
			self.activePiece:draw()
			love.graphics.setShader()
		end
	end
	
	function b:update(dt)
		for j,row in ipairs(self.layout) do
        	for i,piece in ipairs(row) do
        		if piece.type and piece ~= self.activePiece then
        			piece:update(dt, true)
        		end
        	end
        end
       if self.activePiece.type then
        	local x, y = love.mouse.getPosition()
			self.activePiece.t.x, self.activePiece.t.y = x - self.sqDim / 2, y - self.sqDim / 2
			self.activePiece:update(dt, false)
			timer = timer + dt
      	 	rainbow:send("time",timer)
        end
	end
	
	function b:mousePressed(x,y,button)
		local i, j = self:nearestPosition(x, y)
		if self.moveColor == self.layout[i][j].color then
			self.activePiece = self.layout[i][j]
			local o, p = self:getCoordinates(i,j)
			self.activePiece:reset(x - self.sqDim / 2, y - self.sqDim / 2, o, p)
		end
	end
	
	function b:mouseReleased(x,y)
		if self.activePiece.type then
			local i, j = self:nearestPosition(x,y)
			local success, takenPiece = self.activePiece:move(i,j)
			if success then
				print(self.layout[i][j].type..(takenPiece.type and "x" or "")..ord(i)..j)
				self.moveColor = self.moveColor == "R" and "B" or "R"
			end
		end
	end
	
	function b:getCoordinates(i,j)
		return	self.b + self.x + (flipped and self.sqDim * 8 or 0) + (flipped and -1 or 1) * (i - 1) * self.sqDim - self.sqDim / 2,
				self.b + self.y + (flipped and self.sqDim * 9 or 0) + (flipped and -1 or 1) * (j - 1) * self.sqDim - self.sqDim / 2
	end
	
	function b:nearestPosition(x, y)
		local i = (flipped and 10 or 0) + (flipped and -1 or 1) * math.ceil((x - (self.x + self.b) + self.sqDim / 2) / self.sqDim)
		local j = (flipped and 11 or 0) + (flipped and -1 or 1) * math.ceil((y - (self.y + self.b) + self.sqDim / 2) / self.sqDim)
		return round(i,j)
	end
	
	function b:findChecks(onColor)
		local otherColor = (onColor == "R") and "B" or "R"
		local checkExists = false
		for i, row in ipairs(self.layout) do
			for j, piece in ipairs(row) do
				if piece.color == otherColor then checkExists = 
					piece:canMove(self.kingPositions[onColor][1],self.kingPositions[onColor][2])
				end
				if checkExists then return checkExists, onColor end
			end
		end
	end
	
	--load pieces according to layout into table
	b.layout = {[0] = {[0] = emptySpace}}
	function b:loadLayout()
		for i = 1, 9, 1 do
			self.layout[i] = {}
			for j = 1, 10, 1 do
				self.layout[i][j] = emptySpace
			end
		end
	
		for j,i in pairs(layouts[kind]) do
			if type(j) == "number" then for k,v in pairs(i) do
    			self.layout[k][j] = Piece:new(self, layouts[kind][j][k][1], layouts[kind][j][k][2], k, j)
			end end
		end
    	
    	self.moveColor = "R"
    	self.activePiece = emptySpace
    	flipped = false
    end
    b:loadLayout()
    
	return b
end