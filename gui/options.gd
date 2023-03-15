extends Node

const DEFAULT_FOV := 24

@export var post_process_blur: Material: Material
@export var post_process_dither_band: Material: Material
@export var environment: Environment: Environment
@export var path_to_world_viewport: NodePath: NodePath

@onready var world_viewport: SubViewport = get_node(path_to_world_viewport)


func _ready():
	set_fov(DEFAULT_FOV)


func set_fov(value: int):
	Engine.set_target_fps(value)


func set_post_process(enabled: bool):
	post_process_blur.set_shader_parameter("enabled", enabled)


func set_color_depth(value: int):
	post_process_dither_band.set_shader_parameter("col_depth", value)


func set_dither_banding(enabled: bool):
	post_process_dither_band.set_shader_parameter("dither_banding", enabled)


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
	world_viewport.msaa = SubViewport.MSAA_4X if enabled else SubViewport.MSAA_DISABLED


func set_limit_colors(enabled: bool):
	post_process_dither_band.set_shader_parameter("enabled", enabled)
