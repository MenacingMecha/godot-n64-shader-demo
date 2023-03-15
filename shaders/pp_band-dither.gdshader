shader_type canvas_item;
// originally based on https://github.com/WittyCognomen/godot-psx-shaders-demo/blob/master/shaders/psx_dither_post.shader

uniform sampler2D dither_tex: hint_default_white, filter_nearest, repeat_enable;
uniform float col_depth = 24.0;
uniform bool dither_banding = true;
uniform bool enabled = true;

void fragment() {
	COLOR = texture(TEXTURE, SCREEN_UV);

	if (enabled)
	{
		vec2 dith_size = vec2(textureSize(dither_tex,0)); // for GLES2: substitute for the dimensions of the dithering matrix
		vec2 buf_size = vec2(textureSize(TEXTURE,0));
		vec3 dith = texture(dither_tex, SCREEN_UV*(buf_size/dith_size)).rgb;
		dith -= 0.5;
		COLOR.rgb = round(COLOR.rgb*col_depth + dith * (dither_banding ? 1.0 : 0.0)) / col_depth;
	}
}
