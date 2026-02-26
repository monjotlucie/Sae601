extends Area2D

@export var player_group := "player"
@export var bounce_strength := 900.0  

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group(player_group):
		return

	var gdir := 1
	if "gravity_dir" in body:
		gdir = body.gravity_dir

	if "velocity" in body:
		body.velocity.y = -bounce_strength * gdir
