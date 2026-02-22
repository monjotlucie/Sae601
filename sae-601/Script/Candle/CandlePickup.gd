extends Area2D

@export var player_group_name := "player"
var picked := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if picked:
		return
	if body.is_in_group(player_group_name):
		picked = true
		GameState.add_candle()
		get_parent().queue_free()
