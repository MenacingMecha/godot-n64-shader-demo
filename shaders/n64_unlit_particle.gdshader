shader_type spatial;
render_mode depth_draw_alpha_prepass, unshaded;

uniform vec4 modulate_color : hint_color = vec4(1.);
uniform sampler2D albedoTex : hint_albedo;
uniform vec2 uv_scale = vec2(1.0, 1.0);
uniform vec2 uv_offset = vec2(.0, .0);
uniform bool billboard = false;
uniform bool y_billboard = false;
uniform float alpha_scissor : hint_range(0, 1) = 0.1;

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
	UV = UV * uv_scale + uv_offset;

	if (y_billboard)
	{
		MODELVIEW_MATRIX = INV_CAMERA_MATRIX * mat4(CAMERA_MATRIX[0],WORLD_MATRIX[1],vec4(normalize(cross(CAMERA_MATRIX[0].xyz,WORLD_MATRIX[1].xyz)), 0.0),WORLD_MATRIX[3]);
		MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(vec4(1.0, 0.0, 0.0, 0.0),vec4(0.0, 1.0/length(WORLD_MATRIX[1].xyz), 0.0, 0.0), vec4(0.0, 0.0, 1.0, 0.0),vec4(0.0, 0.0, 0.0 ,1.0));
	}
	else if (billboard)
	{
		mat4 mat_world = mat4(normalize(CAMERA_MATRIX[0])*length(WORLD_MATRIX[0]),normalize(CAMERA_MATRIX[1])*length(WORLD_MATRIX[0]),normalize(CAMERA_MATRIX[2])*length(WORLD_MATRIX[2]),WORLD_MATRIX[3]);
		// MODELVIEW_MATRIX = INV_CAMERA_MATRIX * mat4(CAMERA_MATRIX[0],CAMERA_MATRIX[1],CAMERA_MATRIX[2],WORLD_MATRIX[3]);
		mat_world *= mat4( vec4(cos(INSTANCE_CUSTOM.x),-sin(INSTANCE_CUSTOM.x), 0.0, 0.0), vec4(sin(INSTANCE_CUSTOM.x), cos(INSTANCE_CUSTOM.x), 0.0, 0.0),vec4(0.0, 0.0, 1.0, 0.0),vec4(0.0, 0.0, 0.0, 1.0));
		MODELVIEW_MATRIX = INV_CAMERA_MATRIX * mat_world;
	}

	// POSITION = get_snapped_pos(PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0));  // snap position to grid
	// POSITION /= abs(POSITION.w);  // discard depth for affine mapping

	if (y_billboard)
	{
		MODELVIEW_MATRIX = INV_CAMERA_MATRIX * mat4(CAMERA_MATRIX[0],CAMERA_MATRIX[1],CAMERA_MATRIX[2],WORLD_MATRIX[3]);
		MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(vec4(length(WORLD_MATRIX[0].xyz), 0.0, 0.0, 0.0),vec4(0.0, length(WORLD_MATRIX[1].xyz), 0.0, 0.0),vec4(0.0, 0.0, length(WORLD_MATRIX[2].xyz), 0.0),vec4(0.0, 0.0, 0.0, 1.0));
	}

	VERTEX = VERTEX;  // it breaks without this
}

void fragment()
{
	// vec4 tex = texture(albedoTex, UV) * modulate_color * COLOR;
	vec4 tex = n64BilinearFilter(COLOR, UV) * modulate_color;
	ALPHA = tex.a;
	ALBEDO = tex.rgb;
	// ALPHA_SCISSOR = alpha_scissor;
}
