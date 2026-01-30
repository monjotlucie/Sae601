extends Node2D

@onready var player := $CharacterBody2D
@onready var map := $Map

func _ready():
	print("MAIN READY")

	if player == null:
		push_error("❌ Player introuvable")
		return

	if map == null:
		push_error("❌ Map introuvable")
		return

	if not player.has_signal("day_night_changed"):
		push_error("❌ Signal day_night_changed manquant dans Player")
		return

	if not map.has_method("switch_mode"):
		push_error("❌ Méthode switch_mode manquante dans Map")
		return

	player.day_night_changed.connect(map.switch_mode)
	print("✅ Signal jour/nuit connecté")
