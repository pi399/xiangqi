function Starfield(num)
	local c = {}
	local w,h = love.graphics.getDimensions()
	local math = math
	num = num or 600
	c.fg = love.graphics.newCanvas()
	c.mg = love.graphics.newCanvas()
	c.bg = love.graphics.newCanvas()
	c.by,c.my,c.fy = 0, 0, 0
	
	love.graphics.setCanvas(c.fg)
	for i = 1, num do
		local lum = math.max(math.random(),0.7) * math.max(math.random(),0.6)
		love.graphics.setPointSize(math.max(lum * 4,2))
		love.graphics.setColor(lum,lum,lum)
		love.graphics.points(math.random(5, w - 5), math.random(0, h))
	end
	
	love.graphics.setCanvas(c.mg)
	love.graphics.setPointSize(2)
	for i = 1, num * 1.5 do
		local lum = math.max(math.random(),0.6) * math.max(math.random(),0.6)
		love.graphics.setColor(lum,lum,lum,0.5)
		love.graphics.points(math.random(5, w - 5), math.random(0, h))
	end
	
	love.graphics.setCanvas(c.bg)
	love.graphics.setPointSize(1.5)
	for i = 1, num * 2 do
		local lum = math.max(math.random(),0.6) * math.max(math.random(),0.5)
		love.graphics.setColor(lum,lum,lum,0.4)
		love.graphics.points(math.random(5, w - 5), math.random(0, h))
	end
	love.graphics.setCanvas()
	
	function c:draw()
		love.graphics.setColor(1,1,1)
		love.graphics.draw(self.bg,0,self.by)
		love.graphics.draw(self.mg,0,self.my)
		love.graphics.draw(self.fg,0,self.fy)
		local h = love.graphics.getHeight()
		love.graphics.draw(self.bg,0,self.by - h)
		love.graphics.draw(self.mg,0,self.my - h)
		love.graphics.draw(self.fg,0,self.fy - h)
	end
	
	function c:update(dt)
		local h = love.graphics.getHeight()
		self.by = self.by > h and 0 or self.by + dt
		self.my = self.my > h and 0 or self.my + dt * 1.5
		self.fy = self.fy > h and 0 or self.fy + dt * 3
	end

	return c
end