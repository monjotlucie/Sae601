extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var spawn_point: Marker2D = $SpawnPoint
@onready var label: Label = $AnimatedSprite2D/CanvasLayer/Label

var player_inside := false
var player_ref: Player = null
var busy := false 

func _ready():
	sprite.play("idle")
	label.visible = false

func _on_body_entered(body):
	if body is Player:
		player_inside = true
		player_ref = body

		var msg := "Voulez-vous sauvegarder ?\n"
		msg += "Pour sauvegarder, appuyez sur E.\n\n"
		msg += "Voulez-vous retourner au point de départ ?\n"
		msg += "Pour y retourner, appuyez sur R."

		show_message(msg)

func _on_body_exited(body):
	if body is Player:
		player_inside = false
		player_ref = null
		hide_message()

func _process(_delta):
	if not player_inside:
		return

	# E : activer + sauvegarder
	if Input.is_action_just_pressed("interact"):
		activate_checkpoint()
		GameState.save_game()

	if Input.is_action_just_pressed("return_to_start"):
		return_to_start()

func activate_checkpoint():
	if GameState.active_checkpoint and GameState.active_checkpoint != self:
		GameState.active_checkpoint.deactivate()

	GameState.active_checkpoint = self
	GameState.respawn_position = spawn_point.global_position
	print("Checkpoint activé à :", GameState.respawn_position)
	sprite.play("active")

func deactivate():
	sprite.play("idle")

func return_to_start() -> void:
	if busy:
		return
	busy = true
	
	var p := player_ref
	if p == null or not is_instance_valid(p):
		busy = false
		return

	await p.return_to_start_with_respawn(GameState.start_position)


	GameState.active_checkpoint = null
	GameState.respawn_position = GameState.start_position

	busy = false


var typing_id := 0

func show_message(full_text: String) -> void:
	label.visible = true
	_typewriter(full_text)

func hide_message() -> void:
	typing_id += 1
	label.visible = false
	label.text = ""

func _typewriter(full_text: String) -> void:
	typing_id += 1
	var my_id := typing_id

	label.text = ""

	for i in full_text.length():
		if my_id != typing_id:
			return
		label.text = full_text.substr(0, i + 1)
		await get_tree().create_timer(0.02).timeout
