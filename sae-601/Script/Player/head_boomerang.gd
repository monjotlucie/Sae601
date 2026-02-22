extends CharacterBody2D

@export var speed := 800.0
@export var max_distance := 500.0

var direction := 1
var start_position := Vector2.ZERO

func _ready():
	start_position = global_position
	
	$Hitbox.body_entered.connect(_on_hitbox_body_entered)
	$Hitbox.area_entered.connect(_on_hitbox_area_entered)

func _physics_process(delta):
	velocity = Vector2(direction * speed, 0)
	move_and_slide()

	if global_position.distance_to(start_position) > max_distance:
		queue_free()

func _on_hitbox_area_entered(area):
	if area.is_in_group("enemies"):
		if area.has_method("die"):
			area.die()
		else:
			area.queue_free()

func _on_hitbox_body_entered(body):
	if body.is_in_group("enemies"):
		if body.has_method("die"):
			body.die()
		else:
			body.queue_free()
