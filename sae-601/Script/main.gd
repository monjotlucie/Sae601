extends Node2D

@onready var player: Player = $Joueur
@onready var spawn_point: Marker2D = $Marker2D
@onready var pause_menu = $PauseMenu
@onready var fade = $FadeLayer

var cam: Camera2D

func _ready():
	player.respawn_requested.connect(_on_player_respawn)
	print("PAUSED ?", get_tree().paused)


	GameState.candles_changed.connect(_on_candles_changed)

	cam = Camera2D.new()
	add_child(cam)
	cam.make_current()

	cam.position_smoothing_enabled = false
	cam.position_smoothing_speed = 8.0
	cam.position = Vector2(0, 150)

	if GameState.open_pause_menu_on_load:
		GameState.open_pause_menu_on_load = false
		pause_menu.open()

func _on_candles_changed(current: int, total: int) -> void:
	if current >= total:
		print("Toutes les bougies ont été récupérées !")

func _on_player_respawn():
	await fade.fade_out(0.3)

	if GameState.respawn_position != Vector2.ZERO:
		player.global_position = GameState.respawn_position
	else:
		player.global_position = spawn_point.global_position

	player.revive()
	await fade.fade_in(0.3)

func _process(delta):
	if player == null or cam == null:
		return

	cam.global_position.x = player.global_position.x
	cam.global_position.y = player.global_position.y - 150

func _input(event):
	if event.is_action_pressed("pause"):
		if pause_menu.visible:
			pause_menu.close()
		else:
			pause_menu.open()
