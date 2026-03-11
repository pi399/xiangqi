function Spring(springiness,damping,px,py)
	local s = {}
	s.spr = springiness
	s.damp = damping
	s.v = {x = 0, y = 0}
	s.p = {x = px, y = py}
	s.t = {x = px, y = py}
	function s:tick(dt)
		local decelX, decelY = dt * self.damp * self.v.x, dt * self.damp * self.v.y
		if math.abs(self.v.x) > math.abs(decelX) then
			self.v.x = self.v.x - decelX
		else
			self.v.x = 0
		end
		if math.abs(self.v.y) > math.abs(decelY) then
			self.v.y = self.v.y - decelY
		else
			self.v.y = 0
		end
		self.v.x = self.v.x + dt * self.spr * (self.t.x - self.p.x)
		self.v.y = self.v.y + dt * self.spr * (self.t.y - self.p.y)
		self.p.x = self.p.x + dt * self.v.x
		self.p.y = self.p.y + dt * self.v.y
	end
	
	function s:reset(x,y,z,j)
		self.v.x,self.v.y = 0,0
		self.t.x,self.t.y = x,y
		if y and j then
			self.p.x = z
			self.p.y = j
		else
			self.p.x = x
			self.p.y = y
		end
	end
	return s
end