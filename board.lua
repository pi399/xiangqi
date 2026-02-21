require("piece")
--require("layout")

local emptySpace = { type = " ", character = " " }

function Board()
	
	local b = {}
	
	b.mainColors= {0,0,0}
	b.bgColors 	= {0.8,0.8,0.5}

	b.sqDim		= 45
	b.height	= b.sqDim * 9
	b.width		= b.sqDim * 8
	b.b			= b.sqDim / 1.75
	b.x			= 100
	b.y			= 100
	b.cx, b.cy 	= b.x + b.width / 2, b.y + b.height / 2
	b.theta		= 0

	function b:draw()
	
		love.graphics.push()
		love.graphics.translate(self.cx,self.cy)
		love.graphics.rotate(self.theta)
		love.graphics.translate(-self.cx,-self.cy)

		--draw bg
		love.graphics.setColor(self.bgColors)
		love.graphics.rectangle("fill", self.x-self.b, self.y-self.b,
								self.width + self.b * 2, self.height + self.b * 2,
								self.b, self.b)
		love.graphics.setColor(self.mainColors)
		love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

		--draw lines
		for i = 1,7,1 do
			love.graphics.line(
				self.x + self.sqDim * i,
				self.y,
				self.x + self.sqDim * i,
				self.y + self.sqDim * 4 )
			love.graphics.line(
				self.x + self.sqDim * i,
				self.y + self.sqDim * 5,
				self.x + self.sqDim * i,
				self.y + self.height)
		end

		for j = 1,8,1 do
			love.graphics.line(
				self.x,
				self.y + self.sqDim * j,
				self.x + self.width,
				self.y + self.sqDim * j)
		end
		
		love.graphics.line(
					self.x + self.sqDim * 3, 
					self.y,
					self.x + self.sqDim * 5,
					self.y + self.sqDim * 2 )
		love.graphics.line(
					self.x + self.sqDim * 5,
					self.y,
					self.x + self.sqDim * 3,
					self.y + self.sqDim * 2 )
		love.graphics.line(
					self.x + self.sqDim * 3,
					self.y + self.sqDim * 7,
					self.x + self.sqDim * 5,
					self.y + self.height )
		love.graphics.line(
					self.x + self.sqDim * 5,
					self.y + self.sqDim * 7,
					self.x + self.sqDim * 3,
					self.y + self.height )
		
		--draw pieces
		for i,piece in ipairs(self.pieces) do
        	piece:draw()
        end
        
        love.graphics.pop()
	end
	
	function b:update(dt)
		for i,piece in ipairs(self.pieces) do
        	piece:update()
        end
	end
	
	function b:resize(dimension)
		self.sqDim = dimension
		self.height = dimension * 9
		self.width = dimension * 8
		self.b = dimension / 2
		self.cx, self.cy = self.x + self.width / 2, self.y + self.height / 2
		for i,piece in ipairs(self.pieces) do
			piece:update()
		end
	end
	
	function b:getCoordinates(i,j)
		
		return {self.x + (i - 1) * self.sqDim,
				self.y + (j - 1) * self.sqDim}
	
	end

	--load pieces according to layout into tables
	b.layout = {}
	b.pieces = {}
	
	for j = 1, 10, 1 do
		b.layout[j] = {}
		for i = 1, 9, 1 do
			b.layout[j][i] = emptySpace
		end
	end
	
	for j,i in pairs(starting_layout) do
    	for k,v in pairs(i) do
    		b.layout[k][j] = newPiece(b, starting_layout[j][k][1], starting_layout[j][k][2], k, j)
    		table.insert(b.pieces, b.layout[k][j])
		end
    end
	
	return b
	
end