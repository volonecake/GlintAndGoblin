extends Node2D

@export var arena_rect := Rect2i(0, 0, 1280, 768)
@export var heal_every_n_waves: int = 3

@onready var player = $Entities/Player
@onready var camera: GameCamera = $Entities/Player/GameCamera
@onready var wave_manager: WaveManager = $WaveManager
@onready var pause_menu = $PauseMenu
@onready var game_over = $GameOver
@onready var wave_label: Label = $HUD/Labels/WaveLabel
@onready var hp_label: Label = $HUD/Labels/HPLabel
@onready var enemies_label: Label = $HUD/Labels/EnemiesLabel
@onready var banner: Label = $HUD/Banner

func _ready() -> void:
	camera.set_limits(arena_rect)
	player.health_changed.connect(_on_health_changed)
	player.died.connect(_on_player_died)
	wave_manager.wave_started.connect(_on_wave_started)
	wave_manager.wave_cleared.connect(_on_wave_cleared)
	wave_manager.enemies_changed.connect(
		func(n: int): enemies_label.text = "Enemies: %d" % n)
	banner.modulate.a = 0.0
	_on_health_changed(player.health, player.max_health)
	wave_manager.start()

func _on_health_changed(current: int, maximum: int) -> void:
	hp_label.text = "HP: %d/%d" % [current, maximum]

func _on_wave_started(wave: int) -> void:
	wave_label.text = "Wave %d" % wave
	banner.text = "WAVE %d" % wave
	banner.modulate.a = 1.0
	create_tween().tween_property(banner, "modulate:a", 0.0, 1.5).set_delay(1.0)

func _on_wave_cleared(wave: int) -> void:
	if wave % heal_every_n_waves == 0:
		player.heal(1)

func _on_player_died() -> void:
	wave_manager.stop()
	pause_menu.can_pause = false
	await get_tree().create_timer(0.8).timeout   # brief beat before the screen appears
	var new_best := SaveData.submit_wave(wave_manager.wave)
	game_over.show_results(wave_manager.wave, SaveData.best_wave, new_best)
