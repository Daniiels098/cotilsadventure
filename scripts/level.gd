class_name Level extends Node2D

@export var player:Player
@export var doors:Array[Door]
var data:LevelDataHandoff
@onready var pause_menu = $MenuPause
var game_paused = false
var button_layer = preload("res://scenes/controlsTouch.tscn")
var button_layer_canhoto = preload("res://scenes/controlsTouchCanhoto.tscn")

func _ready():
	if player != null:
		player.disable_mode
		player.visible = false
	if data == null:
		enter_level()
	choose_button_layer()

func choose_button_layer():
	var settings = ConfigFileHandler.load_settings()
	if settings.has("Controle") and settings["Controle"].has("canhoto"):
		if settings["Controle"]["canhoto"]:
			var canhoto_instance = button_layer_canhoto.instance()
			add_child(canhoto_instance)
		else:
			var destro_instance = button_layer.instance()
			add_child(destro_instance)
	else:
		print("Configuração de 'canhoto' não encontrada.")

func load_button_layout():
	var settings = ConfigFileHandler.load_settings()
	if settings.has("Controle") and settings["Controle"].has("canhoto"):
		var is_canhoto = settings["Controle"]["canhoto"]
		var scene_to_load
		if is_canhoto:
			scene_to_load = preload("res://scenes/controlsTouchCanhoto.tscn")
		else:
			scene_to_load = preload("res://scenes/controlsTouch.tscn")
		var current_scene = get_tree().current_scene
		if current_scene:
			current_scene.queue_free()
		get_tree().root.add_child(scene_to_load.instance())
	else:
		print("Configuração de 'canhoto' não encontrada.")

func enter_level() -> void:
	if data != null:
		init_player_location()
	if player != null:
		player.enable()
	_connect_to_doors()

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		game_paused = !game_paused
		if game_paused:
			Engine.time_scale = 0
			pause_menu.visible = true
		else:
			Engine.time_scale = 1
			pause_menu.visible = false
		get_tree().root.get_viewport().set_input_as_handled()

func init_player_location() -> void:
	#ta dando erro de null pq o level que o boneco vai nao tem player pra dar assign
	if data != null:
		for door in doors:
			if door.name == data.entry_door_name:
				player.position = door.get_player_entry_vector()
		if player != null:
			player.orient(data.move_dir)

func _on_player_entered_door(door:Door) -> void:
	_disconnect_from_doors()
	player.disable()
	player.queue_free()
	data = LevelDataHandoff.new()
	data.entry_door_name = door.entry_door_name
	data.move_dir = door.get_move_dir()
	set_process(false)

func _connect_to_doors() -> void:
	for door in doors:
		if not door.player_entered_door.is_connected(_on_player_entered_door):
			door.player_entered_door.connect(_on_player_entered_door)

func _disconnect_from_doors() -> void:
	for door in doors:
		if door.player_entered_door.is_connected(_on_player_entered_door):
			door.player_entered_door.disconnect(_on_player_entered_door)
