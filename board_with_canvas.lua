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
	
	b.mainColors	= {0,0,0}
	b.bgColors		= {0.8,0.8,0.5}
	b.baseDim		= 90
	b.x				= 100
	b.y				= 100
	b.scale			= 0.5
	b.theta			= 0
	b.sqDim, b.height, b.width, b.b, b.cx, b.cy = 0,0,0,0,0,0
	
	function b:values(i)
		self.sqDim = self.baseDim * (i or self.scale)
		self.height = self.sqDim * 9
		self.width = self.sqDim * 8
		self.b = self.sqDim / 1.75
		self.cx, self.cy = self.b + self.x + self.width / 2, self.b + self.y + self.height / 2
	end
	
	function b:createBoardCanvas()
		
		self:values(1)
		local canvas = love.graphics.newCanvas(self.width + self.b * 2, self.height + self.b * 2)
		love.graphics.setCanvas(canvas)
		love.graphics.setColor(self.bgColors)
		love.graphics.rectangle("fill", 0, 0,
							self.width + self.b * 2, self.height + self.b * 2,
							self.b, self.b)
		love.graphics.setColor(self.mainColors)
		love.graphics.rectangle("line", self.b, self.b, self.width, self.height)

		--draw lines
		for i = 1,7,1 do
			love.graphics.line(
				self.b + self.sqDim * i,
				self.b,
				self.b + self.sqDim * i,
				self.b + self.sqDim * 4 )
			love.graphics.line(
				self.b + self.sqDim * i,
				self.b + self.sqDim * 5,
				self.b + self.sqDim * i,
				self.b + self.height)
		end
	
		for j = 1,8,1 do
			love.graphics.line(
				self.b,
				self.b + self.sqDim * j,
				self.b + self.width,
				self.b + self.sqDim * j)
		end
			
		love.graphics.line(
					self.b + self.sqDim * 3, 
					self.b,
					self.b + self.sqDim * 5,
					self.b + self.sqDim * 2 )
		love.graphics.line(
					self.b + self.sqDim * 5,
					self.b,
					self.b + self.sqDim * 3,
					self.b + self.sqDim * 2 )
		love.graphics.line(
					self.b + self.sqDim * 3,
					self.b + self.sqDim * 7,
					self.b + self.sqDim * 5,
					self.b + self.height )
		love.graphics.line(
					self.b + self.sqDim * 5,
					self.b + self.sqDim * 7,
					self.b + self.sqDim * 3,
					self.b + self.height )
		love.graphics.setCanvas()
		self:values()
		return canvas
	end
	
	b.canvas = b:createBoardCanvas()
	
	function b:draw()
		
		love.graphics.push()
		love.graphics.translate(self.cx,self.cy)
		love.graphics.rotate(self.theta)
		love.graphics.translate(-self.cx,-self.cy)
		
		--draw bg
		love.graphics.setColor(self.bgColors)
		love.graphics.draw(self.canvas,self.x,self.y,0,self.scale,self.scale)
		
		--draw pieces
		for j,row in ipairs(self.layout) do
        	for i,piece in ipairs(row) do
        		if piece.type then
        			piece:draw()
        		end
        	end
        end
        
        love.graphics.pop()
	end
	
	function b:update(dt)
		for i,piece in ipairs(self.layout) do
        	if piece.type then piece:update() end
        end
	end
	
	function b:resize(dimension)
		self.scale = dimension or self.scale
		self:values()
		self:update()
	end
	
	function b:getCoordinates(i,j)
		
		return	self.b + self.x + (i - 1) * self.sqDim,
				self.b + self.y + (j - 1) * self.sqDim
	
	end
	
	function b:nearestPosition(x, y)
		local i = math.floor((x - self.x) / self.sqDim) + 1
		local j = math.floor((y - self.y) / self.sqDim) + 1
		return round(i,j)
	end
	
	--load pieces according to layout into table
	b.layout = {}
	
	for j = 1, 10, 1 do
		b.layout[j] = {}
		for i = 1, 9, 1 do
			b.layout[j][i] = emptySpace
		end
	end
	
	for j,i in pairs(starting_layout) do
    	for k,v in pairs(i) do
    		b.layout[k][j] = newPiece(b, starting_layout[j][k][1], starting_layout[j][k][2], k, j)
		end
    end
	
	return b
	
end