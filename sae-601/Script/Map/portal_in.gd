extends Area2D

@export var player_group := "player"
@export var cooldown := 0.3

var _locked := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if _locked:
		return
	if not body.is_in_group(player_group):
		return

	var out := get_parent().get_node_or_null("PortalOut") as Marker2D
	if out == null:
		push_error("PortalOut introuvable : il doit être enfant de PortalPair.")
		return

	_locked = true

	if "velocity" in body:
		body.velocity = Vector2.ZERO

	body.global_position = out.global_position
	print("Teleported to: ", out.global_position)

	await get_tree().create_timer(cooldown).timeout
	_locked = false
