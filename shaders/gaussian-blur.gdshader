shader_type canvas_item;

uniform float h = 1;
uniform float v = 0;
uniform bool enabled = true;

void fragment()
{
	// float kernel[] = {0.06136, 0.24477, 0.38774, 0.24477, 0.06136};
	float kernel[] = {0.31946576033846985, 0.3610684793230603, 0.31946576033846985};
	vec2 px = TEXTURE_PIXEL_SIZE;
	vec4 col = vec4(0);

	if (enabled)
	{
		for (int i = 0; i < kernel.length(); i++)
		{
			// int radius = (kernel.length() - 1) / 2;  // This is wrong for some reason?
			int radius = 1;
			int distance = i - radius;
			col += texture(TEXTURE, UV + px * vec2(h * float(distance), v * float(distance))) * kernel[i];
		}
		COLOR = col;
	}
	else
	{
		COLOR = texture(TEXTURE, UV);
	}
}
