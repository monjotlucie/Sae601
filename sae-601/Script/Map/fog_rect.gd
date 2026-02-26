extends ColorRect

@export var player_path: NodePath
@export var radius := 200.0
@export var softness := 30.0

@onready var _mat := material as ShaderMaterial
@onready var _player := get_node(player_path) as Player

func _process(_delta: float) -> void:
	if _player == null or _mat == null:
		return

	var cam := get_viewport().get_camera_2d()
	if cam == null:
		return

	var player_screen: Vector2 = cam.unproject_position(_player.global_position)

	_mat.set_shader_parameter("player_pos", player_screen)
	_mat.set_shader_parameter("radius", radius)
	_mat.set_shader_parameter("softness", softness)
