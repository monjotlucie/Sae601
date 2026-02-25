extends Area2D

@export var player_group := "player"

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group(player_group):
		body.controls_inverted = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group(player_group):
		body.controls_inverted = false
