extends Node

signal save_game_request
var save_timer: Timer
var game_loaded := false

func _ready():
	save_timer = Timer.new()
	save_timer.wait_time = 180 # 3 minutos
	save_timer.connect("timeout", Callable(self, "_on_save_timer_timeout"))
	add_child(save_timer)
	save_timer.start()

func _on_save_timer_timeout():
	emit_signal("save_game_request")