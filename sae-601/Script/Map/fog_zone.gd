extends Area2D

@export var player_group := "player"
@export var overlay_path: NodePath
@export var exit_delay := 0.2

var _inside := 0

func _ready() -> void:
	body_entered.connect(_on_enter)
	body_exited.connect(_on_exit)

func _on_enter(body: Node) -> void:
	if not body.is_in_group(player_group):
		return
	_inside += 1
	_apply(body, true)

func _on_exit(body: Node) -> void:
	if not body.is_in_group(player_group):
		return
	_inside = maxi(_inside - 1, 0)
	await get_tree().create_timer(exit_delay).timeout
	if _inside == 0:
		_apply(body, false)

func _apply(player: Node, active: bool) -> void:
	if "in_fog" in player:
		player.in_fog = active

	var overlay := get_node_or_null(overlay_path)
	if overlay != null:
		overlay.visible = active
