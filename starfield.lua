function Starfield(num)
	local starfield = {}
	local screen_width, screen_height = love.graphics.getDimensions()
	
	local random = love.math.random
	for i = 1, num do
		local color = math.max(random(),0.3) * math.max(random(),0.3)
		local speed = 10 * color * random()
		starfield[i] = {
			random(5, screen_width-5),
			random(5, screen_height - 5),
			["speed"] = speed,
			["color"] = { color, color, color }
		}
	end
	
	function starfield:draw()
		for i, star in ipairs(self) do   -- loop through all of our stars
			love.graphics.setColor(star.color)
			love.graphics.points(star[1], star[2])   -- draw each point
		end
	end
	
	function starfield:update(dt)
		local _, screen_height = love.graphics.getDimensions()
		for i, star in ipairs(self) do   -- loop through all of our stars
			star[2] = star[2] + star.speed * dt
			if star[2] > screen_height then star[2] = 0 end
		end
	end
	
	return starfield
end