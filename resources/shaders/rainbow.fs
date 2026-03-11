extern number time;
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
	{
		vec4 pixel = Texel( texture, texture_coords );
		pixel.r = pixel.r * 1.1 + sin(time) / 5.0;
		pixel.g = pixel.g * 1.1 + cos(time) / 5.0;
		pixel.b = pixel.b * 1.1 + sin(time) / 5.0;
		return pixel;
	}