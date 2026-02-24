require("piece")

local emptySpace = { type = false, character = false }
local function round(x,y)
	if x < 1 then x = 1
	elseif x > 9 then x = 9 end
	if y < 1 then y = 1
	elseif y > 10 then y = 10 end
	return x,y
end


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
	
	function b:createBoardImage()
		local image = love.graphics.newImage("resources/textures/2x/board.png")
		image:setFilter("nearest","nearest")
		return image
	end
	
	b.image = b:createBoardImage()
	
	function b:draw()
		
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
        
        love.graphics.pop()
		if self.activePiece.type then self.activePiece:draw() end --draw selected piece on top of everything
	end
	
	function b:update(dt)
		for j,row in ipairs(self.layout) do
        	for i,piece in ipairs(row) do
        		if piece.type and piece ~= self.activePiece then
        			piece:update()
        		end
        	end
        end
	end
	
	function b:getCoordinates(i,j)
		return	self.b + self.x + (i - 1) * self.sqDim - 29,
				self.b + self.y + (j - 1) * self.sqDim - 29
	end
	
	function b:nearestPosition(x, y)
		local i = math.floor((x - (self.x + self.b) + 87) / self.sqDim)
		local j = math.floor((y - (self.y + self.b) + 87) / self.sqDim) 
		
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
	b.layout = {}
	
	for i = 1, 9, 1 do
		b.layout[i] = {}
		for j = 1, 10, 1 do
			b.layout[i][j] = emptySpace
		end
	end
	
	for j,i in pairs(starting_layout) do
    	for k,v in pairs(i) do
    		b.layout[k][j] = newPiece(b, starting_layout[j][k][1], starting_layout[j][k][2], k, j)
		end
    end
	
	b.activePiece = emptySpace
	
	return b
	
end