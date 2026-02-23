extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var spawn_point: Marker2D = $SpawnPoint

var player_inside := false
var player_ref: Player = null
var busy := false 


func _ready():
	sprite.play("idle")

func _on_body_entered(body):
	if body is Player:
		player_inside = true
		player_ref = body

func _on_body_exited(body):
	if body is Player:
		player_inside = false
		player_ref = null

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
