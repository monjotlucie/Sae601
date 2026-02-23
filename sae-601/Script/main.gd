extends Node2D

@onready var player: Player = $Joueur
@onready var spawn_point: Marker2D = $Marker2D
@onready var pause_menu = $PauseMenu
@onready var fade = $FadeLayer
@onready var circle_candles: Node = $CircleCandles

var cam: Camera2D


func _ready():
	player.respawn_requested.connect(_on_player_respawn)
	print("PAUSED ?", get_tree().paused)
	GameState.start_position = spawn_point.global_position

	GameState.candles_changed.connect(_on_candles_changed)
	GameState.candle_collected.connect(_on_candle_collected)

	for cid in GameState.collected_candles:
		_show_circle_candle(cid)
	cam = Camera2D.new()
	add_child(cam)
	cam.make_current()

	cam.position_smoothing_enabled = false
	cam.position_smoothing_speed = 8.0
	cam.position = Vector2(0, 150)
	
	cam.limit_left = 0
	cam.limit_top = 0
	cam.limit_right = 2800    
	cam.limit_bottom = 1040  

	if GameState.open_pause_menu_on_load:
		GameState.open_pause_menu_on_load = false
		pause_menu.open()

func _on_candles_changed(current: int, total: int) -> void:
	if current >= total:
		print("Toutes les bougies ont été récupérées !")

func _on_candle_collected(candle_id: String) -> void:
	_show_circle_candle(candle_id)

func _show_circle_candle(candle_id: String) -> void:
	var n := circle_candles.get_node_or_null(candle_id)
	if n != null:
		n.visible = true

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
	cam.global_position.y = player.global_position.y + 150

func _input(event):
	if event.is_action_pressed("pause"):
		if pause_menu.visible:
			pause_menu.close()
		else:
			pause_menu.open()
