local characters = 
{
	R = {
		K = "帥",
		R = "俥",
		H = "馬",
    	C = "炮",
	   	P = "兵",
    	A = "仕",
		E = "相"
	},

	B = {
		K = "將",
		R = "車",
    	H = "馬",
		C = "砲",
		P = "卒",
		A = "士",
		E = "象"
	}
}

local emptySpace = { type = false, character = false }
local function inBounds(x,y,low_x,high_x,low_y,high_y)
	return x >= (low_x or 1) and x <= (high_x or 9) and y >= (low_y or 1) and y <= (high_y or 10)
end

local pawn1 = {["moves"]={0,-1},["threats"]={0,-1},["blocks"]=nil,["confines"]=nil}
local pawn2 = {["moves"]={{0,-1},{1,0},{-1,0}},["threats"]={{0,-1},{1,0},{-1,0}},["blocks"]=nil,["confines"]=nil}
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
			--[["canMove"]	= function(p,i,j)
				for k = -10, 10, 1 do
					if p.row + k == i and p.column == j then
						for l = p.row, 
					elseif p.row == i and p.column + k == j then
						return true
					end
				end
			end,]]
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
	   		["canMove"]	= function(p,i,j)
				for k = -10, 10, 1 do
					if (p.row + k == i and p.column == j or
						p.row == i and p.column + k == j) then
						return true
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
			["canMove"]	= function(p,i,j)
				for k = -10, 10, 1 do
					if (p.row + k == i and p.column == j or
						p.row == i and p.column + k == j) then
						return true
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
	   		["canMove"]	= function(p,i,j)
				for k = -10, 10, 1 do
					if (p.row + k == i and p.column == j or
						p.row == i and p.column + k == j) then
						return true
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
	p.character		= characters[color][type] or "無"
	p.bodyColors	= {1,1,1}
	p.textColors	= {color=="R" and 1 or 0,0,0}
	p.board			= board
	p.size			= 20
	p.row			= i
	p.column		= j
	p.x, p.y		= board:getCoordinates(i,j)

	function p:draw()
		local x = self.x
		local y = self.y
		
		love.graphics.setColor(self.bodyColors)
		love.graphics.circle("fill",x,y,self.size)
		love.graphics.setColor(self.textColors)
		love.graphics.circle("line",x,y,self.size)
		love.graphics.print(self.character,x-self.size*.6,y-self.size*.95)
	end

	function p:move(i,j)
		if inBounds(i,j) then
			self.board.layout[self.row][self.column] = emptySpace
			self.row = i
			self.column = j
			self.board.layout[i][j] = self
			self:update()
		end
	end
	
	generateRules(p,p.color,p.type)
	
	function p:canMove(i,j)
		if self.board.layout[i][j].color == self.color then return false end --cannot take your own piece
		if inBounds(i,j) then return self:canTypeMove(i,j) end
		--[[for k, v in ipairs(self.rules.moves) do
			local move_x, move_y = unpack(v)
			if self.row + move_x == i and self.column + move_y == j then
				if self.rules.blocks then
					local check_x, check_y = self.row + self.rules.blocks[k][1], self.column + self.rules.blocks[k][2]
					if self.board.layout[check_x][check_y].type then return false end	--cannot move if blocked
				end
				return not (self.rules.confines and not inBounds(i, j, unpack(self.rules.confines)))	--make sure you're within bounds
			end
		end]]
	end
	
	function p:update() self.x, self.y = board:getCoordinates(self.row, self.column) end
	function p:position() return self.row, self.column end
	
	return p
end

function generateRules(piece,color,type)
	function piece:canTypeMove(i,j)
		return rules[color][type].canMove(piece,i,j)
	end
end