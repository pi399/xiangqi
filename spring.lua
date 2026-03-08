function Spring(springiness,damping,position)
	local s = {}
	s.spr = springiness
	s.damping = damping
	s.velocity = 0
	s.p = position
	s.t = position
	function s:tick(dt)
		local deceleration = dt * self.damping * self.velocity
		if math.abs(self.velocity) > math.abs(deceleration) then
			self.velocity = self.velocity - deceleration
		else
			self.velocity = 0
		end
		self.velocity = self.velocity + dt * self.spr * (self.t - self.p)
		self.p = self.p + dt * self.velocity
	end
	
	function s:reset(x,y)
		self.velocity = 0
		self.t = x
		if y then
			self.p = y
		else
			self.p = x
		end
	end
	return s
end