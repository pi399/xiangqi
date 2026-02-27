require("piece")
require("spring")

local emptySpace = { type = false, character = false }
local function round(x,y)
	if x < 1 then x = 1
	elseif x > 9 then x = 9 end
	if y < 1 then y = 1
	elseif y > 10 then y = 10 end
	return x,y
end

local mousePressed = false
local flipped = false

function Board()
	
	local b = {}
	
	local w, h = love.graphics.getDimensions()
	
	b.mainColors	= {0,0,0}
	b.bgColors		= {0.8,0.8,0.5}
	b.baseDim		= 60
	b.sqDim			= 60
	b.b				= 80
	b.width			= b.sqDim * 8
	b.height		= b.sqDim * 9
	b.x				= w/2 - ( b.width + b.b * 2 ) / 2
	b.y				= h/2 - ( b.height + b.b * 2 ) / 2
	b.theta			= 0
	
	b.kingPositions = {R = {5, 10}, B = {5, 1}}
	b.moveColor		= "R"
	b.layout		= {}
	
	function b:createBoardImage()
		self.image = love.graphics.newImage("resources/textures/2x/board.png")
		self.image:setFilter("nearest","nearest")
	end
	
	b:createBoardImage()
	
	function b:draw()
		--rotate depending on theta
		love.graphics.push()
		love.graphics.translate(self.x,self.y)
		love.graphics.rotate(self.theta)
		love.graphics.translate(-self.x,-self.y)
		
		--draw board
		love.graphics.setColor(self.bgColors)
		love.graphics.draw(self.image,self.x,self.y)
		
		--draw pieces, except for the selected piece
		for j,row in ipairs(self.layout) do
        	for i,piece in ipairs(row) do
        		if piece.type and piece ~= self.activePiece then
        			piece:draw()
        		end
        	end
        end
        
        --draw selected piece last
		if self.activePiece.type then self.activePiece:draw() end
        love.graphics.pop()
	end
	
	function b:update(dt)
		local dt = dt or love.timer.step()
	
		for j,row in ipairs(self.layout) do
        	for i,piece in ipairs(row) do
        		if piece.type and piece ~= self.activePiece then
        			piece:update(dt, true)
        		end
        	end
        end
        
		if self.activePiece.type then
			if mousePressed then
				local x, y = love.mouse.getPosition()
				self.activePiece.xspr.t, self.activePiece.yspr.t = x - 30, y - 30
			end
			self.activePiece:update(dt, false)
		end
	end
	
	function b:mousePressed(x,y,button)
		mousePressed = true
		local i, j = self:nearestPosition(x, y)
		if self.moveColor == self.layout[i][j].color then
			self.activePiece = self.layout[i][j]
			local o, p = self:getCoordinates(i,j)
			self.activePiece.xspr:reset(x - 30, o)
			self.activePiece.yspr:reset(y - 30, p)
		end
	end
	
	function b:mouseReleased(x,y)
		mousePressed = false
		if self.activePiece.type then
			local i, j = self:nearestPosition(x,y)
			if self.activePiece:move(i,j) then
				self.moveColor = self.moveColor == "R" and "B" or "R"
				--self:reverse()
			end
		end
	end
	
	function b:center()
		local w,h		= love.graphics.getDimensions()
		self.x, self.y	= w/2 - ( self.width + self.b * 2 ) / 2, h/2 - ( self.height + self.b * 2 ) / 2
	end
	
	function b:getCoordinates(i,j)
		return	self.b + self.x + (flipped and self.width or 0) + (flipped and -1 or 1) * (i - 1) * self.sqDim - 29,
				self.b + self.y + (flipped and self.height or 0) + (flipped and -1 or 1) * (j - 1) * self.sqDim - 29
	end
	
	function b:nearestPosition(x, y)
		local i = (flipped and 10 or 0) + (flipped and -1 or 1) * math.floor((x - (self.x + self.b) + 87) / self.sqDim)
		local j = (flipped and 11 or 0) + (flipped and -1 or 1) * math.floor((y - (self.y + self.b) + 87) / self.sqDim)
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
	
	function b:reverse(reset)
		if reset then
			flipped = false
		else
			flipped = not flipped
		end
	end
	
	--load pieces according to layout into table
	function b:loadLayout()
		for i = 1, 9, 1 do
			self.layout[i] = {}
			for j = 1, 10, 1 do
				self.layout[i][j] = emptySpace
			end
		end
		
		for j,i in pairs(starting_layout) do
    		for k,v in pairs(i) do
    			self.layout[k][j] = newPiece(self, starting_layout[j][k][1], starting_layout[j][k][2], k, j)
			end
    	end
    	
    	self.moveColor = "R"
    	self.activePiece = emptySpace
    	self:reverse(true)
    end
    
	b:loadLayout()
	return b
end