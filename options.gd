extends Node

export(Material) var post_process_blur : Material
export(Material) var post_process_dither_band : Material
export(Environment) var environment : Environment
export(NodePath) var path_to_world_viewport : NodePath

onready var world_viewport : Viewport = get_node(path_to_world_viewport)

func _ready():
	set_fov(24)

func set_fov(value: int):
	Engine.set_target_fps(value)

func set_post_process(enabled: bool):
	post_process_blur.set_shader_param("enabled", enabled)

func set_color_depth(value: int):
	post_process_dither_band.set_shader_param("col_depth", value)

func set_dither_banding(enabled: bool):
	post_process_dither_band.set_shader_param("dither_banding", enabled)

func set_fog_enabled(enabled: bool):
	environment.set_fog_enabled(enabled)

func set_fog_color(color: Color):
	environment.set_fog_color(color)

func set_fog_depth_begin(value: float):
	environment.set_fog_depth_begin(value)

func set_fog_depth_end(value: float):
	environment.set_fog_depth_end(value)

func set_ambient_light_color(color: Color):
	environment.set_ambient_light_color(color)

func set_ambient_energy(value: float):
	environment.set_ambient_light_energy(value)

func set_aa(enabled: bool):
	world_viewport.msaa = Viewport.MSAA_4X if enabled else Viewport.MSAA_DISABLED