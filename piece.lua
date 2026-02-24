--require("spring")

local pieceImages = {B = {}, R = {}}
local image = love.graphics.newImage("resources/textures/2x/pieces.png")
image:setFilter("nearest","nearest")
if true then
	local i = 1
	local order = {"K", "R", "H", "C", "P", "A", "E", [0] = " "}
	for y = 0,3,1 do
		local color = (y < 2) and "B" or "R"
		for x = 0,3,1 do
			pieceImages[color][order[i % 8]] = love.graphics.newQuad(x*58,y*58,58,58,image)
			i = i + 1
		end
	end
end

--local springs = { X = Spring(500,20,0), Y = Spring(500,20,0) }
local emptySpace = { type = false, character = false }
local function inBounds(x,y,low_x,high_x,low_y,high_y)
	return x >= (low_x or 1) and x <= (high_x or 9) and y >= (low_y or 1) and y <= (high_y or 10)
end

local horseMoves = {{2,1},{-2,1},{2,-1},{-2,-1},{1,2},{-1,2},{1,-2},{-1,-2}}
local horseBlocks= {{1,0},{-1,0},{1,0}, {-1,0}, {0,1},{0,1}, {0,-1},{0,-1}}

local rules =
{
	R = { 
		K = {
			["canMove"]	= function(p,i,j)
				for k = -1, 1, 2 do
					if (p.row + k == i and p.column == j or
						p.row == i and p.column + k == j) then
						return inBounds(i,j,4,6,8,10)
					end
				end
			end,
			["moves"]	= {{1,0},{-1,0},{0,1},{0,-1}},
			["threats"]	= {{1,0},{-1,0},{0,1},{0,-1},{0,"K"}},
			["blocks"]	= nil,
			["confines"]= {4, 6, 8, 10} --red palace
		},
		R = {
			["canMove"]	= function(p,i,j)
				for k = -10, 10, 1 do
					if k ~= 0 then
						local sign = k < 0 and -1 or 1
						if p.row + k == i and p.column == j then
							for l = p.row + sign, p.row + k - sign, sign do
								if p.board.layout[l][p.column].type then return false end
							end
							return true
						elseif p.row == i and p.column + k == j then
							for l = p.column + sign, p.column + k - sign, sign do
								if p.board.layout[p.row][l].type then return false end
							end
							return true
						end
					end
				end
			end,
			["moves"]	= {{"R",0},{0,"R"}},
			["threats"] = {{"R",0},{0,"R"}},
			["blocks"]	= nil,
			["confines"]= nil
		},
		H = {
			["canMove"] = function(p,i,j)
				for k, v in ipairs(horseMoves) do
					if (p.row + v[1] == i and p.column + v[2] == j) then
						return not p.board.layout[p.row + horseBlocks[k][1]][p.column + horseBlocks[k][2]].type
					end
				end
			end,
			["threats"] = {{2,1},{-2,1},{2,-1},{-2,-1},{1,2},{-1,2},{1,-2},{-1,-2}},
			["blocks"]	= {{1,0},{-1,0},{1,0}, {-1,0}, {0,1},{0,1}, {0,-1},{0,-1}},
			["confines"]= nil
		},
	   	C = {
	   		["canMove"] = function(p,i,j)
	   			local pieceExists = p.board.layout[i][j].type
				for k = -10, 10, 1 do
					if k ~= 0 then
						local sign = k < 0 and -1 or 1
						local counter = 0
						if p.row + k == i and p.column == j then
							for l = p.row + sign, p.row + k - sign, sign do
								counter = counter + (p.board.layout[l][p.column].type and 1 or 0)
							end
							return counter == 1 and pieceExists or counter == 0 and not pieceExists
						elseif p.row == i and p.column + k == j then
							for l = p.column + sign, p.column + k - sign, sign do
								counter = counter + (p.board.layout[p.row][l].type and 1 or 0)
							end
							return counter == 1 and pieceExists or counter == 0 and not pieceExists
						end
					end
				end
			end,
	   		["moves"]	= {{"R",0},{0,"R"}},
	   		["threats"]	= {{"C",0},{0,"C"}},
	   		["blocks"]	= nil,
	   		["confines"]= nil
	   	},
	   	P = {
	   		["canMove"]	= function(p,i,j)
				if p.row == i and p.column - 1 == j then return true 
				elseif inBounds(i,j, 1, 9, 1, 5) then
					return p.row - 1 == i and p.column == j or p.row + 1 == i and p.column == j
				end
			end,
	   		["moves"]	= {{0,-1}},
	   		["threats"]	= {{0,-1}},
	   		["blocks"]	= nil,
	   		["confines"]= nil
	   	},
	   	A = {
	   		["canMove"] = function(p,i,j)
				for k = -1, 1, 2 do
					for l = -1, 1, 2 do
						if (p.row + k == i and p.column + l == j)
							and inBounds(i,j,4,6,7,10) then return true end
					end
				end
			end,
	   		["threats"]	= {{1,1},{1,-1},{-1,1},{-1,-1}},
	   		["blocks"]	= nil,
	  		["confines"]= {4, 6, 8, 10}	--red palace
	    },
		E = {
			["canMove"] = function(p,i,j)
				for k = -2, 2, 4 do
					for l = -2, 2, 4 do
						if (p.row + k == i and p.column + l == j)
							and not p.board.layout[p.row + k/2][p.column + l/2].type
							and inBounds(i,j,1,9,6,10) then return true end
					end
				end
			end,
			["moves"]	= {{2,2},{-2,2},{2,-2},{-2,-2}},
			["threats"]	= {{2,2},{-2,2},{2,-2},{-2,-2}},
			["blocks"]	= {{1,1},{-1,1},{1,-1},{-1,-1}},
			["confines"]= {1, 9, 6, 10} --red side before river
		}
	}
}

rules.B = {
	K = {
		["canMove"]	= function(p,i,j)
			for k = -1, 1, 2 do
				if (p.row + k == i and p.column == j or
					p.row == i and p.column + k == j) then
					return inBounds(i,j,4,6,1,3)
				end
			end
		end,
		["moves"]	= {{1,0},{-1,0},{0,1},{0,-1}},
		["threats"]	= {{1,0},{-1,0},{0,1},{0,-1},{0,"K"}},
		["blocks"]	= nil,
		["confines"]= {4, 6, 1, 3} --black palace
	},
	R = {
		["canMove"]	= rules.R.R.canMove,
		["moves"]	= {{"R",0},{0,"R"}},
		["threats"] = {{"R",0},{0,"R"}},
		["blocks"]	= nil,
		["confines"]= nil
	},
	H = {
		["canMove"] = rules.R.H.canMove,
		["threats"] = {{2,1},{-2,1},{2,-1},{-2,-1},{1,2},{-1,2},{1,-2},{-1,-2}},
		["blocks"]	= {{1,0},{-1,0},{1,0}, {-1,0}, {0,1},{0,1}, {0,-1},{0,-1}},
		["confines"]= nil
	},
   	C = {
   		["canMove"]	= rules.R.C.canMove,
   		["moves"]	= {{"R",0},{0,"R"}},
   		["threats"]	= {{"C",0},{0,"C"}},
   		["blocks"]	= nil,
   		["confines"]= nil
   	},
   	P = {
  		["canMove"]	= function(p,i,j)
			if p.row == i and p.column + 1 == j then return true 
			elseif inBounds(i,j, 1, 9, 6, 10) then
				return p.row - 1 == i and p.column == j or p.row + 1 == i and p.column == j
			end
		end,
   		["moves"]	= {{0,1}},
   		["threats"]	= {{0,1}},
   		["blocks"]	= nil,
   		["confines"]= nil
   	},
   	A = {
   		["canMove"] = function(p,i,j)
			for k = -1, 1, 2 do
				for l = -1, 1, 2 do
					if (p.row + k == i and p.column + l == j)
						and inBounds(i,j,4,6,1,3) then return true end
				end
			end
		end,
   		["moves"]	= {{1,1},{1,-1},{-1,1},{-1,-1}},
   		["threats"]	= {{1,1},{1,-1},{-1,1},{-1,-1}},
   		["blocks"]	= nil,
  		["confines"]= {4, 6, 1, 3} --black palace
    },
	E = {
		["canMove"] = function(p,i,j)
			for k = -2, 2, 4 do
				for l = -2, 2, 4 do
					if (p.row + k == i and p.column + l == j)
						and not p.board.layout[p.row + k/2][p.column + l/2].type
						and inBounds(i,j,1,9,1,5) then return true end
				end
			end
		end,
		["moves"]	= {{2,2},{-2,2},{2,-2},{-2,-2}},
		["threats"]	= {{2,2},{-2,2},{2,-2},{-2,-2}},
		["blocks"]	= {{1,1},{-1,1},{1,-1},{-1,-1}},
		["confines"]= {1, 9, 1, 5} --black side before river
	}
}

function newPiece(board,color,type,i,j)
	
	local p = {}

	p.type			= type
	p.color			= color
	p.bodyColors	= {1,1,1}
	p.textColors	= {color=="R" and 1 or 0,0,0}
	p.board			= board
	p.size			= 20
	p.row			= i
	p.column		= j
	p.x, p.y		= board:getCoordinates(i,j)

	function p:draw()
		love.graphics.setColor(1,1,1)
		love.graphics.draw(image,pieceImages[self.color][self.type], self.x, self.y, 0, 1.75*self.board.scale, 1.75*self.board.scale)
	end

	function p:move(i,j)
		if self:canMove(i,j) then
			self.board.layout[self.row][self.column] = emptySpace
			local save, save_row, save_column = self.board.layout[i][j], self.row, self.column
			self.row = i
			self.column = j
			self.board.layout[i][j] = self
			
			if self.type == "K" then
				self.board.kingPositions[self.color] = {i,j}
			end
			
			if self.board:findChecks(self.color) then		--if you have checked yourself, undo the move. maybe there is a more efficient way?
				self.row, self.column = save_row, save_column
				self.board.layout[i][j] = save
				self.board.layout[self.row][self.column] = self
				if self.type == "K" then
					self.board.kingPositions[self.color] = {save_row, save_column}
				end
				return false
			end
			self:update()
			return true
		end
		return false
	end
	
	function p:generateRules(color,type)
		function self:canTypeMove(i,j)
			return rules[color or self.color][type or self.type].canMove(self,i,j)
		end
	end
	
	p:generateRules()
	
	function p:canMove(i,j)
		if self.board.layout[i][j].color == self.color then return false end --cannot take your own piece
		return inBounds(i,j) and self:canTypeMove(i,j)
	end
	
	function p:update() self.x, self.y = board:getCoordinates(self.row, self.column) end	
	return p
end