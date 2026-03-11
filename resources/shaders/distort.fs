extern number time;
	vec4 effect(vec4 color, Image tex, vec2 tc, vec2 pc)
		{
			tc.x += sin(tc.y * 100 + time * 10.0) * .02  * exp(-2 * time);
			return Texel(tex,tc);
		}