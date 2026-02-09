extends CharacterBody2D

# =========================
# NODES
# =========================
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var vision: Area2D = $Vision
@onready var ground_check: RayCast2D = $RayCast2D

# =========================
# PARAMÈTRES
# =========================
@export var speed := 80.0
@export var gravity := 1200.0
@export var attack_distance := 120.0
@export var attack_delay := 0.3

# =========================
# ÉTAT
# =========================
var direction := -1        # -1 = gauche, 1 = droite
var player: CharacterBody2D = null
var attacking := false

# =========================
# READY
# =========================
func _ready():
	sprite.play("fixe_guerrier")

	# Configure le RayCast dans la bonne direction
	ground_check.target_position.x = abs(ground_check.target_position.x) * direction

# =========================
# PHYSICS
# =========================
func _physics_process(delta):
	# Gravité
	if not is_on_floor():
		velocity.y += gravity * delta

	# Si on attaque → on ne fait RIEN d'autre
	if attacking:
		velocity.x = 0
		move_and_slide()
		return

	# Patrouille
	velocity.x = direction * speed

	# Vérification sol
	if not ground_check.is_colliding():
		turn_around()

	# Interaction joueur
	if player:
		handle_player_interaction()

	# Flip sprite (CORRIGÉ)
	sprite.flip_h = direction < 0

	move_and_slide()


# =========================
# PATROUILLE
# =========================
func turn_around():
	direction *= -1
	ground_check.target_position.x = abs(ground_check.target_position.x) * direction

# =========================
# JOUEUR
# =========================
func handle_player_interaction():
	var distance := global_position.distance_to(player.global_position)

	# Se tourner vers le joueur
	if player.global_position.x < global_position.x:
		direction = -1
	else:
		direction = 1

	# Patrouille / poursuite
	velocity.x = direction * speed


	# Attaque
	if distance <= attack_distance:
		attack()

	# Se tourner vers le joueur
	direction = -1 if player.global_position.x < global_position.x else 1

	# Attaque
	if distance <= attack_distance:
		attack()


# =========================
# ATTAQUE
# =========================
func attack():
	if attacking or player == null:
		return

	attacking = true
	velocity.x = 0

	var target := player  # 🔒 verrouillage de la cible

	sprite.play("attaque_guerrier")

	await get_tree().create_timer(attack_delay).timeout

	if target and target.has_method("die"):
		target.die()

	attacking = false
	sprite.play("fixe_guerrier")


# =========================
# VISION (AREA2D)
# =========================
func _on_Vision_body_entered(body):
	if body.name == "Player":
		player = body

func _on_Vision_body_exited(body):
	if body == player:
		if attacking:
			return # on ignore la sortie pendant l’attaque

		player = null
		sprite.play("fixe_guerrier")
