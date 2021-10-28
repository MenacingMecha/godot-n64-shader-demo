shader_type spatial;
render_mode unshaded, shadows_disabled, blend_add, depth_draw_alpha_prepass, cull_disabled;

void fragment()
{
	ALBEDO = COLOR.rgb;
	ALPHA = 1.0 - UV.y;
}
