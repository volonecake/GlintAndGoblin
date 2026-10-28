class_name WaveManager
extends Node

signal wave_started(wave: int)
signal wave_cleared(wave: int)
signal enemies_changed(remaining: int)

@export var entities: Node2D          # enemies get added here
@export var spawn_points: Node2D      # parent of the Marker2Ds
@export var enemy_pool: Array[WaveEnemy] = []

@export_group("Difficulty")
@export var base_budget: int = 4
@export var budget_per_wave: int = 2
@export var health_scale_per_wave: float = 0.08
@export var speed_scale_per_wave: float = 0.01
@export var max_speed_mult: float = 1.5
@export var max_alive: int = 25

@export_group("Timing")
@export var intermission: float = 3.0
@export var spawn_interval: float = 0.35
@export var min_spawn_distance: float = 180.0

var wave := 0
var alive := 0
var remaining := 0   # alive + not yet spawned
var running := false
var player: Node2D

func start() -> void:
	player = get_tree().get_first_node_in_group("player")
	running = true
	_run()

func stop() -> void:
	running = false

func _run() -> void:
	while running:
		wave += 1
		wave_started.emit(wave)
		await _wait(intermission)
		if not running:
			return

		var queue := _build_queue()
		remaining = queue.size()
		enemies_changed.emit(remaining)

		for entry in queue:
			while running and alive >= max_alive:
				await _wait(0.25)
			if not running:
				return
			_spawn(entry)
			await _wait(spawn_interval)

		while running and remaining > 0:
			await _wait(0.25)
		if running:
			wave_cleared.emit(wave)

func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds, false).timeout   # false = respects pause

func _build_queue() -> Array[WaveEnemy]:
	var budget := base_budget + budget_per_wave * (wave - 1)
	var queue: Array[WaveEnemy] = []
	while budget > 0:
		var options := enemy_pool.filter(
			func(e: WaveEnemy) -> bool: return e.min_wave <= wave and e.cost <= budget)
		if options.is_empty():
			break
		var pick := _weighted_pick(options)
		queue.append(pick)
		budget -= pick.cost
	queue.shuffle()
	return queue

func _weighted_pick(options: Array) -> WaveEnemy:
	var total := 0.0
	for o in options:
		total += o.weight
	var roll := randf() * total
	for o in options:
		roll -= o.weight
		if roll <= 0.0:
			return o
	return options.back()

func _spawn(entry: WaveEnemy) -> void:
	var pos := _pick_spawn_position()
	alive += 1   # count now so the wave cant end while a telegraph is pending

	var telegraph := SpawnTelegraph.new()
	entities.add_child(telegraph)
	telegraph.global_position = pos
	await telegraph.finished

	if not running:   # player dies during the telegraph
		alive -= 1
		return

	var enemy := entry.scene.instantiate() as Enemy
	var n := wave - 1
	enemy.max_health = ceili(enemy.max_health * (1.0 + health_scale_per_wave * n))
	enemy.speed *= minf(1.0 + speed_scale_per_wave * n, max_speed_mult)
	enemy.contact_timer = 0.5   # can't hurt the player while fading in
	enemy.modulate.a = 0.0
	enemy.died.connect(_on_enemy_died)
	entities.add_child(enemy)
	enemy.global_position = pos
	create_tween().tween_property(enemy, "modulate:a", 1.0, 0.3)
func _pick_spawn_position() -> Vector2:
	var points := spawn_points.get_children()
	points.shuffle()
	for p in points:
		var marker := p as Node2D
		if player == null or marker.global_position.distance_to(player.global_position) >= min_spawn_distance:
			return marker.global_position
	return (points[0] as Node2D).global_position

func _on_enemy_died(_enemy: Enemy) -> void:
	alive -= 1
	remaining -= 1
	enemies_changed.emit(remaining)
