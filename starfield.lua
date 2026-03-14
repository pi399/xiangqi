local nebula = love.graphics.newImage("resources/textures/photo/milky_way.jpg")
local nw,nh = nebula:getDimensions()
function Starfield(num)
	local c = {}
	local math = math
	c.fg = love.graphics.newCanvas()
	c.mg = love.graphics.newCanvas()
	c.bg = love.graphics.newCanvas()
	c.by,c.my,c.fy = 0, 0, 0
	
	function c:generateStars(count,xin,yin,win,hin)
		local num = count or num or 600
		local x = xin or 0
		local y = yin or 0
		local w = win or love.graphics.getWidth()
		local h = hin or love.graphics.getHeight()
		
		love.graphics.setCanvas(self.fg)
		for i = 1, num do
			local lum = math.max(math.random(),0.7) * math.max(math.random(),0.6)
			love.graphics.setPointSize(math.max(lum * 4,2))
			love.graphics.setColor(lum-0.05,lum,lum+0.05)
			love.graphics.points(math.random(x, x + w), math.random(y, y + h))
		end
		
		love.graphics.setCanvas(self.mg)
		love.graphics.setPointSize(2)
		for i = 1, num * 1.5 do
			local lum = math.max(math.random(),0.7) * math.max(math.random(),0.6)
			love.graphics.setColor(lum,lum,lum,0.8)
			love.graphics.points(math.random(x, x + w), math.random(y, y + h))
		end
		
		love.graphics.setCanvas(self.bg)
		love.graphics.setPointSize(2)
		for i = 1, num * 2 do
			local lum = math.max(math.random(),0.7) * math.max(math.random(),0.6)
			love.graphics.setColor(lum+math.random() * 0.05,lum,lum-math.random() * 0.05,0.6)
			love.graphics.points(math.random(x, x + w), math.random(y, y + h))
		end
		love.graphics.setCanvas()
	end
	c:generateStars()
	
	function c:draw()
		local h = self.fg:getHeight()
		local w,wh = love.graphics.getDimensions()
		love.graphics.draw(nebula,0,0,0,w/nw,wh/nh)
		love.graphics.setColor(1,1,1)
		love.graphics.draw(self.bg,0,self.by)
		love.graphics.draw(self.mg,0,self.my)
		love.graphics.draw(self.fg,0,self.fy)
		love.graphics.draw(self.bg,0,self.by - h)
		love.graphics.draw(self.mg,0,self.my - h)
		love.graphics.draw(self.fg,0,self.fy - h)
	end
	
	function c:update(dt)
		local h = self.fg:getHeight()
		self.by = self.by > h and 0 or self.by + dt * 0.5
		self.my = self.my > h and 0 or self.my + dt
		self.fy = self.fy > h and 0 or self.fy + dt * 3
	end
	
	function c:resize(w,h)
		local pw, ph = self.fg:getDimensions()
		local dw, dh = w - pw, h - ph
		if dw > 0 or dh > 0 then
			local fg,mg,bg = self.fg,self.mg,self.bg
			self.fg = love.graphics.newCanvas(w,h)
			love.graphics.setCanvas(self.fg)
			love.graphics.setColor(1,1,1)
			love.graphics.draw(fg)
			self.mg = love.graphics.newCanvas(w,h)
			love.graphics.setCanvas(self.mg)
			love.graphics.setColor(1,1,1)
			love.graphics.draw(mg)
			self.bg = love.graphics.newCanvas(w,h)
			love.graphics.setCanvas(self.bg)
			love.graphics.setColor(1,1,1)
			love.graphics.draw(bg)
		else return end
		
		if dw > 0 then
			self:generateStars(dw,pw,0,dw,h)
		end
		
		if dh > 0 then
			self:generateStars(dh,0,ph,pw,dh)
		end
	end

	return c
end
