extends Area2D

@export var player_group := "player"
@export var enter_delay := 0.35
@export var exit_delay := 0.35

var _inside := 0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group(player_group):
		return
	
	_inside += 1
	_apply_enter_later(body)

func _on_body_exited(body: Node) -> void:
	if not body.is_in_group(player_group):
		return
	
	_inside = max(_inside - 1, 0)
	_apply_exit_later(body)

func _apply_enter_later(player: Node) -> void:
	await get_tree().create_timer(enter_delay).timeout
	if _inside > 0 and is_instance_valid(player):
		player.controls_inverted = true

func _apply_exit_later(player: Node) -> void:
	await get_tree().create_timer(exit_delay).timeout
	if _inside == 0 and is_instance_valid(player):
		player.controls_inverted = false
