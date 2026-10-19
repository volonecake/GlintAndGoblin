extends CharacterBody2D

@export var aim_linger: float = 0.25

@export_group("Movement")
@export var max_speed: float = 90.0
@export var acceleration: float = 1200.0   # high = more snappy
@export var friction: float = 1600.0       # slightly higher than accel so player stops crisply

@export_group("Dodge Roll")
@export var roll_speed: float = 200.0
@export var roll_duration: float = 0.35
@export var roll_cooldown: float = 0.25
@export var roll_slowdown: float = 600.0   # how quickly the roll bleeds off at the end

@export_group("Shooting")
@export var fireball_scene: PackedScene
@export var fire_rate: float = 4.0         # shots per second
@export var fireball_speed: float = 220.0
@export var muzzle_distance: float = 14.0  # how far from the player's center the fireball spawns


@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var fire_cooldown := 0.0
var is_rolling := false
var is_invulnerable := false
var can_roll := true
var roll_dir := Vector2.ZERO
var roll_time := 0.0
var aim_timer := 0.0
var last_facing := Vector2.DOWN

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	#refreshes timer when attacking
	if Input.is_action_pressed("attack"):
		aim_timer = aim_linger
	else:
		aim_timer = maxf(aim_timer - delta, 0.0)
		
	fire_cooldown -= delta
	if Input.is_action_pressed("attack") and fire_cooldown <= 0.0 and not is_rolling:
		_shoot()
		
	if Input.is_action_just_pressed("dodge") and can_roll and not is_rolling:
		_start_roll(input_dir)

	if is_rolling:
		_process_roll(delta)
	else:
		_process_movement(input_dir, delta)

	move_and_slide()
	_update_animation(input_dir)

func _shoot() -> void:
	fire_cooldown = 1.0 / fire_rate
	aim_timer = aim_linger  # sprite faces the mouse while shooting

	var aim := _aim_dir()
	var fb: Projectile = fireball_scene.instantiate()
	fb.global_position = global_position + aim * muzzle_distance
	fb.velocity = aim * fireball_speed
	fb.rotation = aim.angle()
	get_tree().current_scene.add_child(fb)

func _process_movement(input_dir: Vector2, delta: float) -> void:
	if input_dir != Vector2.ZERO:
		velocity = velocity.move_toward(input_dir * max_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

func _start_roll(input_dir: Vector2) -> void:
	roll_dir = input_dir if input_dir != Vector2.ZERO else _aim_dir()
	is_rolling = true
	is_invulnerable = true
	can_roll = false
	roll_time = 0.0
	velocity = roll_dir * roll_speed

func _process_roll(delta: float) -> void:
	roll_time += delta
	#full speed for the first 60%, then ease out
	if roll_time > roll_duration * 0.6:
		velocity = velocity.move_toward(roll_dir * max_speed * 0.5, roll_slowdown * delta)
	#I-frames last most of the roll but not all of it, so it has a risk window
	if roll_time > roll_duration * 0.8:
		is_invulnerable = false
	if roll_time >= roll_duration:
		is_rolling = false
		is_invulnerable = false
		await get_tree().create_timer(roll_cooldown).timeout
		can_roll = true

func _aim_dir() -> Vector2:
	return (get_global_mouse_position() - global_position).normalized()

func _update_animation(input_dir: Vector2) -> void:
	if is_rolling:
		return #TODO: add rolling animation here

	var attacking := aim_timer > 0.0

	if attacking:
		last_facing = _aim_dir()
	elif input_dir != Vector2.ZERO:
		last_facing = input_dir

	var dir_name := _direction_name(last_facing)

	if input_dir == Vector2.ZERO:
		sprite.play("idle_" + dir_name)
	else:
		sprite.play("walk_" + dir_name)
		
func _direction_name(v: Vector2) -> String:
	if absf(v.x) > absf(v.y):
		return "right" if v.x > 0 else "left"
	return "down" if v.y > 0 else "up"
