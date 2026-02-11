extends AnimatableBody2D

@export var fall_delay := 0.5
@export var respawn_time := 3.0
@export var gravity := 1000.0

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var trigger_area: Area2D = $Area2D

var triggered := false
var velocity := Vector2.ZERO
var start_position := Vector2.ZERO

func _ready():
	start_position = global_position
	trigger_area.body_entered.connect(_on_area_2d_body_entered)

func _physics_process(delta):
	if triggered:
		velocity.y += gravity * delta
		global_position += velocity * delta

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player and not triggered:
		await get_tree().create_timer(1).timeout
		if body and body.is_on_floor():
			start_fall()

func start_fall():
	triggered = true

	# Tremblement
	for i in 5:
		position.x += 3
		await get_tree().create_timer(0.05).timeout
		position.x -= 3
		await get_tree().create_timer(0.05).timeout

	await get_tree().create_timer(fall_delay).timeout

	collision.disabled = true

	await get_tree().create_timer(respawn_time).timeout

	respawn()

func respawn():
	triggered = false
	velocity = Vector2.ZERO
	global_position = start_position
	collision.disabled = false
