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

local pawn1 = {["moves"]={0,-1},["threats"]={0,-1},["blocks"]="none",["confines"]="none"}
local pawn2 = {["moves"]={{0,-1},{1,0},{-1,0}},["threats"]={{0,-1},{1,0},{-1,0}},["blocks"]="none",["confines"]="none"}
local pawnMeta = { __index =
	function(table,key)
		return pawn1[key]
	end}

local rules =
{
	K = {
		["moves"]	= {{1,0},{-1,0},{0,1},{0,-1}},
		["threats"]	= {{1,0},{-1,0},{0,1},{0,-1},{0,"K"}},
		["blocks"]	= "none",
		["confines"]= "palace"
	},
	R = {
		["moves"]	= {{"R",0},{0,"R"}},
		["threats"] = {{"R",0},{0,"R"}},
		["blocks"]	= "none",
		["confines"]= "none"
	},
	H = {
		["moves"]	= {{2,1},{-2,1},{2,-1},{-2,-1},{1,2},{-1,2},{1,-2},{-1,-2}},
		["threats"] = {{2,1},{-2,1},{2,-1},{-2,-1},{1,2},{-1,2},{1,-2},{-1,-2}},
		["blocks"]	= {{1,0},{-1,0},{1,0}, {-1,0}, {0,1},{0,1}, {0,-1},{0,-1}},
		["confines"]= "none"
	},
   	C = {
   		["moves"]	= {{"R",0},{0,"R"}},
   		["threats"]	= {{"C",0},{0,"C"}},
   		["blocks"]	= "none",
   		["confines"]= "none"
   	},
   	P = {
   		["moves"]	= {{0,-1}},
   		["threats"]	= {{0,-1}},
   		["blocks"]	= "none",
   		["confines"]= "none"
   	},
   	A = {
   		["moves"]	= {{1,1},{1,-1},{-1,1},{-1,-1}},
   		["threats"]	= {{1,1},{1,-1},{-1,1},{-1,-1}},
   		["blocks"]	= "none",
  		["confines"]= "palace"
    },
	E = {
		["moves"]	= {{2,2},{-2,2},{2,-2},{-2,-2}},
		["threats"]	= {{2,2},{-2,2},{2,-2},{-2,-2}},
		["blocks"]	= "none",
		["confines"]= "river"
	}
}

local emptySpace = { type = false, character = false }
local function inBounds(x,y) return (x > 0) and (x < 10) and (y > 0) and (y < 11) end

function newPiece(board,color,type,i,j)
	
	local p = {}

	p.type			= type
	p.color			= color
	p.rules			= rules[type]
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
	
	function p:update() self.x, self.y = board:getCoordinates(self.row, self.column) end
	function p:position() return self.row, self.column end
	
	return p
end
