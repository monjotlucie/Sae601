extends Node2D

@export var speed := 800.0

var target_position: Vector2

@onready var hitbox: Area2D = $Hitbox


func _ready():
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	hitbox.area_entered.connect(_on_hitbox_area_entered)

	z_index = 100
	z_as_relative = false


func _process(delta):
	global_position = global_position.move_toward(target_position, speed * delta)

	if global_position.distance_to(target_position) <= 2.0:
		queue_free()


func _kill(target: Node):
	if target == null:
		return

	if not target.is_in_group("enemies") and target.get_parent() != null and target.get_parent().is_in_group("enemies"):
		target = target.get_parent()

	if target.is_in_group("enemies"):
		if target.has_method("die"):
			target.die()
		else:
			target.queue_free()


func _on_hitbox_area_entered(area: Area2D):
	_kill(area)


func _on_hitbox_body_entered(body: Node):
	_kill(body)
