extends Area2D

@export var player_group := "player"
@export var exit_delay := 0.2

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group(player_group):
		body.pending_gravity_reset = false
		body.set_gravity_flipped(true)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group(player_group):
		body.pending_gravity_reset = true
		body.reset_gravity_after_delay(exit_delay)
