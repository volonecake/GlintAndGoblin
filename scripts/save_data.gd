extends Node

const PATH := "user://save.cfg"
var best_wave := 0

func _ready() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) == OK:
		best_wave = cfg.get_value("arena", "best_wave", 0)

# returns true if this is a new record
func submit_wave(wave: int) -> bool:
	if wave <= best_wave:
		return false
	best_wave = wave
	var cfg := ConfigFile.new()
	cfg.set_value("arena", "best_wave", best_wave)
	cfg.save(PATH)
	return true
