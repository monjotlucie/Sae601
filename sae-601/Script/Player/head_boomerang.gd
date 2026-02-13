extends CharacterBody2D

@export var speed := 800.0
@export var max_distance := 500.0

var direction := 1
var start_position := Vector2.ZERO
var offset_x = 150
var player = null

func _ready():
	start_position = global_position
	$Hitbox.body_entered.connect(_on_hitbox_body_entered)
	print("Direction reçue :", direction)



func _on_hitbox_body_entered(body):
	print("Collision détectée avec :", body.name)
	if body.is_in_group("enemies"):
		print("ENNEMI TUÉ")
		body.queue_free()


func _physics_process(delta):

	velocity = Vector2(direction * speed, 0)
	move_and_slide()

	# Supprime après distance max
	if global_position.distance_to(start_position) > max_distance:
		queue_free()

	# Détection collision ennemis
	for i in range(get_slide_collision_count()):
		var col = get_slide_collision(i)
		var body = col.get_collider()

		if body and body.is_in_group("enemies"):
			body.queue_free()
