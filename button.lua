--ui interface
require("board")

Button = {}
local meta = {__index = Button}
local textFunctions = setmetatable({
	["play xiangqi"] = function(self)
		self.visible = false
		return Board("traditional")
	end,
	["blank pieces"] = function(self)
		self.visible = false
		return Board("blanks")
	end,
	["quit"] = function(self)
		love.event.push("quit")
	end
}, {__index = function() return function() return false end end})

function Button:new(x,y,text,callback)
	local b = {}
	b.x = x
	b.y = y
	b.clicked = false
	b.visible = true
	b.callback = callback or textFunctions[text]
	b.text = text
	b.xw = 200
	b.yw = 50
	b.baseColor = {0.8,0.8,0.9}
	b.clickedColor = {b.baseColor[1] - 0.1, b.baseColor[2] - 0.1, b.baseColor[3] - 0.1}
	b.color = b.baseColor
	
	setmetatable(b,meta)
	return b
end

function Button:inBounds(x,y)
	return self.x < x and self.x + self.xw > x and self.y < y and self.y + self.yw > y
end

function Button:draw()
	if not self.visible then return end
	love.graphics.setColor(self.color)
	love.graphics.rectangle("fill",self.x,self.y,self.xw,self.yw)
	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("line",self.x + 5,self.y + 5,self.xw - 10, self.yw - 10)
	love.graphics.print(self.text, self.x + 20, self.y + self.yw / 3)
end

function Button:mousePressed(x,y)
	if not self.visible then return end
	if self:inBounds(x,y) then
		self.color = self.clickedColor
		self.clicked = true
	end
end

function Button:mouseReleased(x,y)
	if not self.visible then return end
	if self.clicked then
		self.color = self.baseColor
		self.clicked = false
		if self:inBounds(x,y) then return self:callback() end
	end
end