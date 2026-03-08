require("spring")

local pieceImages = {B = {}, R = {}}
local image = love.graphics.newImage("resources/textures/2x/pieces.png")
image:setFilter("nearest","nearest")
if true then
	local i = 1
	local order = {"K", "R", "H", "C", "P", "A", "E", [0] = " "}
	--King Rook Horse Cannon Pawn Advisor Elephant Blank
	for y = 0,3,1 do
		local color = (y < 2) and "B" or "R"
		for x = 0,3,1 do
			pieceImages[color][order[i % 8]] = love.graphics.newQuad(x*58,y*58,58,58,image)
			i = i + 1
		end
	end
end

local click = love.audio.newSource("resources/audio/click.mp3", "static")

local emptySpace = { type = false, character = false }
local function inBounds(x,y,low_x,high_x,low_y,high_y)
	return x >= (low_x or 1) and x <= (high_x or 9) and y >= (low_y or 1) and y <= (high_y or 10)
end

local horseMoves = {{2,1},{-2,1},{2,-1},{-2,-1},{1,2},{-1,2},{1,-2},{-1,-2}}
local horseBlocks= {{1,0},{-1,0},{1,0}, {-1,0}, {0,1},{0,1}, {0,-1},{0,-1}}

local rules =
{
	R = { 
		K = function(p,i,j)
				for k = -1, 1, 2 do
					if (p.row + k == i and p.column == j or
						p.row == i and p.column + k == j) then
						return inBounds(i,j,4,6,8,10)
					end
				end
			end,
		R = function(p,i,j)
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
		H = function(p,i,j)
				for k, v in ipairs(horseMoves) do
					if (p.row + v[1] == i and p.column + v[2] == j) then
						return not p.board.layout[p.row + horseBlocks[k][1]][p.column + horseBlocks[k][2]].type
					end
				end
			end,
	   	C = function(p,i,j)
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
	   	P = function(p,i,j)
				if p.row == i and p.column - 1 == j then return true 
				elseif inBounds(i,j, 1, 9, 1, 5) then
					return p.row - 1 == i and p.column == j or p.row + 1 == i and p.column == j
				end
			end,
	   	A = function(p,i,j)
				for k = -1, 1, 2 do
					for l = -1, 1, 2 do
						if (p.row + k == i and p.column + l == j)
							and inBounds(i,j,4,6,8,10) then return true end
					end
				end
			end,
		E = function(p,i,j)
				for k = -2, 2, 4 do
					for l = -2, 2, 4 do
						if (p.row + k == i and p.column + l == j)
							and not p.board.layout[p.row + k/2][p.column + l/2].type
							and inBounds(i,j,1,9,6,10) then return true end
					end
				end
			end
	}
}

rules.B = {
	K = function(p,i,j)
			for k = -1, 1, 2 do
				if (p.row + k == i and p.column == j or
					p.row == i and p.column + k == j) then
					return inBounds(i,j,4,6,1,3)
				end
			end
		end,
	R = rules.R.R,
	H = rules.R.H,
   	C = rules.R.C,
   	P = function(p,i,j)
			if p.row == i and p.column + 1 == j then return true 
			elseif inBounds(i,j, 1, 9, 6, 10) then
				return p.row - 1 == i and p.column == j or p.row + 1 == i and p.column == j
			end
		end,
   	A = function(p,i,j)
			for k = -1, 1, 2 do
				for l = -1, 1, 2 do
					if (p.row + k == i and p.column + l == j)
						and inBounds(i,j,4,6,1,3) then return true end
				end
			end
		end,
	E = function(p,i,j)
			for k = -2, 2, 4 do
				for l = -2, 2, 4 do
					if (p.row + k == i and p.column + l == j)
						and not p.board.layout[p.row + (k/2)][p.column + l/2].type
						and inBounds(i,j,1,9,1,5) then return true end
				end
			end
		end
}

function newPiece(board,color,type,i,j)
	
	local p = {}

	p.type			= type
	p.color			= color
	p.board			= board
	p.size			= 20
	p.row			= i
	p.column		= j
	p.x,  p.y		= board:getCoordinates(i,j)
	p.xspr, p.yspr  = Spring(500,20,p.x), Spring(500,20,p.y + (p.color == "R" and 1 or -1) * math.random(1000))
	
	function p:draw()
		love.graphics.setColor(1,1,1)
		love.graphics.draw(image,pieceImages[self.color][self.type], self.x, self.y)
	end

	function p:move(i,j)
		self.board.activePiece = emptySpace
		if self:canMove(i,j) then
			self.board.layout[self.row][self.column] = emptySpace
			local save, save_row, save_column = self.board.layout[i][j], self.row, self.column
			
			self.row = i
			self.column = j
			self.board.layout[i][j] = self
			
			if self.type == "K" then
				self.board.kingPositions[self.color] = {i,j}
			end
			
			local kingsFacing = self.board.kingPositions.B[1] == self.board.kingPositions.R[1]
			local pieceInBetween = false
			if kingsFacing then
				for l = self.board.kingPositions.B[2] + 1, self.board.kingPositions.R[2] - 1, 1 do
					print(self.board.layout[self.board.kingPositions.B[1]][l].type)
					pieceInBetween = pieceInBetween or self.board.layout[self.board.kingPositions.B[1]][l].type
				end
			end
			
			--if the proposed move puts the moving player in check, or causes the kings to face, then undo the move.
			if (kingsFacing and not pieceInBetween) or self.board:findChecks(self.color) then
				self.row, self.column = save_row, save_column
				self.board.layout[i][j] = save
				self.board.layout[self.row][self.column] = self
				if self.type == "K" then
					self.board.kingPositions[self.color] = {save_row, save_column}
				end
				return false
			end
			
			click:play()
			return true, save
		end
		return false
	end
	
	function p:generateRules(color,type)
		function self:canTypeMove(i,j)
			return rules[color or self.color][type or self.type](self,i,j)
		end
	end
	
	p:generateRules()
	
	function p:canMove(i,j)
		if self.board.layout[i][j].color == self.color then return false end --cannot take your own piece
		return inBounds(i,j) and self:canTypeMove(i,j)
	end
	
	function p:update(dt,snapped)
		local dt = dt or love.timer.step()
		if snapped then
			self.xspr.t, self.yspr.t = board:getCoordinates(self.row, self.column)
		end
		self.xspr:tick(dt) self.yspr:tick(dt)
		self.x, self.y = self.xspr.p, self.yspr.p
	end	
	
	return p
end