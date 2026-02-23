function Spring(springiness,damping,position)
	local s = {}
	s.spr = springiness
	s.damping = damping
	s.velocity = 0
	s.position = position
	s.target = position
	function s:tick(dt)
		local deceleration = dt * self.damping * self.velocity
		if math.abs(self.velocity) > math.abs(deceleration) then
			self.velocity = self.velocity - deceleration
		else
			self.velocity = 0
		end
		self.velocity = self.velocity + dt * self.spr * (self.target - self.position)
		self.position = self.position + dt * self.velocity
	end
	return s
end