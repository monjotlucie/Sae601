extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var spawn_point: Marker2D = $SpawnPoint

var player_inside := false

func _ready():
	sprite.play("idle")


func _on_body_entered(body):
	if body is Player:
		player_inside = true

func _on_body_exited(body):
	if body is Player:
		player_inside = false

func _process(_delta):
	if player_inside and Input.is_action_just_pressed("interact"):
		activate_checkpoint()

func activate_checkpoint():
	if GameState.active_checkpoint and GameState.active_checkpoint != self:
		GameState.active_checkpoint.deactivate()

	GameState.active_checkpoint = self
	GameState.respawn_position = spawn_point.global_position


	print("Checkpoint activé à :", GameState.respawn_position)

	sprite.play("active")

func deactivate():
	sprite.play("idle")
