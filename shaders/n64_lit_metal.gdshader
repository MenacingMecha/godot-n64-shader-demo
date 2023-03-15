shader_type spatial;
render_mode diffuse_lambert, vertex_lighting, cull_disabled, shadows_disabled, specular_disabled;

uniform sampler2D albedoTex : source_color, filter_nearest, repeat_enable;
uniform vec4 modulate_color : source_color = vec4(1.0);
uniform vec4 metal_modulate_color : source_color = vec4(1.0);

// https://www.emutalk.net/threads/emulating-nintendo-64-3-sample-bilinear-filtering-using-shaders.54215/
vec4 n64BilinearFilter(vec4 vtx_color, vec2 texcoord) {
	ivec2 tex_size = textureSize(albedoTex, 0);
	float Texture_X = float(tex_size.x);
	float Texture_Y = float(tex_size.y);

	vec2 tex_pix_a = vec2(1.0/Texture_X,0.0);
	vec2 tex_pix_b = vec2(0.0,1.0/Texture_Y);
	vec2 tex_pix_c = vec2(tex_pix_a.x,tex_pix_b.y);
	vec2 half_tex = vec2(tex_pix_a.x*0.5,tex_pix_b.y*0.5);
	vec2 UVCentered = texcoord - half_tex;

	vec4 diffuseColor = texture(albedoTex,UVCentered);
	vec4 sample_a = texture(albedoTex,UVCentered+tex_pix_a);
	vec4 sample_b = texture(albedoTex,UVCentered+tex_pix_b);
	vec4 sample_c = texture(albedoTex,UVCentered+tex_pix_c);

	float interp_x = modf(UVCentered.x * Texture_X, Texture_X);
	float interp_y = modf(UVCentered.y * Texture_Y, Texture_Y);

	if (UVCentered.x < 0.0)
	{
		interp_x = 1.0-interp_x*(-1.0);
	}
	if (UVCentered.y < 0.0)
	{
		interp_y = 1.0-interp_y*(-1.0);
	}

	diffuseColor = (diffuseColor + interp_x * (sample_a - diffuseColor) + interp_y * (sample_b - diffuseColor))*(1.0-step(1.0, interp_x + interp_y));
	diffuseColor += (sample_c + (1.0-interp_x) * (sample_b - sample_c) + (1.0-interp_y) * (sample_a - sample_c))*step(1.0, interp_x + interp_y);

    return diffuseColor * vtx_color;
}

void vertex()
{
	// Special thanks Adam McLaughlan
	NORMAL = (MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	NORMAL = normalize(NORMAL);
}

void fragment()
{
	// Special thanks Adam McLaughlan
	vec2 norm = vec2(NORMAL.x / 2.0 + 0.5, (-NORMAL.y) / 2.0 + 0.5);
	ALBEDO = n64BilinearFilter(COLOR, norm).rgb;
}
