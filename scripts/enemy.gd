class_name Enemy
extends CharacterBody2D

signal died(enemy: Enemy)

@export_group("Visuals")
@export var sprite_frames: SpriteFrames          # easy reskin for enemies (im too lazy shh)
@export var art_faces_left := true               # make true if the textures face left for default (so it flips the anims around for the right versions)

@export_group("Stats")
@export var max_health: int = 3
@export var speed: float = 50.0
@export var acceleration: float = 600.0
@export var aggro_range: float = 0.0             # 0 = always chases the player

@export_group("Contact Damage")
@export var contact_damage: int = 1
@export var contact_cooldown: float = 0.8        # seconds between hits
@export var knockback_taken: float = 120.0       # push when hit by a fireball
@export var bounce_force: float = 160.0          # how hard recoil is after hitting the player
@export var bounce_stun: float = 0.25            # seconds it can't chase after bouncing
@export var hit_stun: float = 0.12               # secnods of stun when hit by fireball

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox

var health: int
var target: Node2D
var facing_left := true
var contact_timer := 0.0
var flash_tween: Tween
var stun_timer := 0.0

func _ready() -> void:
	health = max_health
	if sprite_frames:
		sprite.sprite_frames = sprite_frames
	target = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	contact_timer -= delta
	stun_timer -= delta

	if stun_timer > 0.0:
		velocity = velocity.move_toward(Vector2.ZERO, acceleration * 1.5 * delta)
	else:
		var chasing := false
		if target != null:
			var to_target := target.global_position - global_position
			chasing = aggro_range <= 0.0 or to_target.length() <= aggro_range
			if chasing:
				velocity = velocity.move_toward(to_target.normalized() * speed, acceleration * delta)
				if absf(to_target.x) > 4.0:
					facing_left = to_target.x < 0.0
		if not chasing:
			velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)

	move_and_slide()
	_check_contact_damage()
	_update_animation()

func _check_contact_damage() -> void:
	if contact_timer > 0.0:
		return
	for area in hitbox.get_overlapping_areas():
		var victim := area.get_parent() as Node2D
		if victim != null and victim.has_method("take_damage"):
			victim.take_damage(contact_damage, global_position)
			contact_timer = contact_cooldown
			# recoils away from the player
			var away := (global_position - victim.global_position).normalized()
			velocity = away * bounce_force
			stun_timer = bounce_stun
			return

func _update_animation() -> void:
	var moving := velocity.length() > 5.0
	var anim := "walk_left" if moving else "idle_left"
	if sprite.animation != anim or not sprite.is_playing():
		sprite.play(anim)
	# only the left animations exists, so flip for right (saves us time :thumbsup: aw theres no emojis here)
	sprite.flip_h = (facing_left != art_faces_left)

func take_damage(amount: int, from_position: Vector2 = Vector2.ZERO) -> void:
	health -= amount
	if from_position != Vector2.ZERO:
		velocity = (global_position - from_position).normalized() * knockback_taken
	stun_timer = hit_stun
	_flash()
	if health <= 0:
		die()

func _flash() -> void:
	if flash_tween:
		flash_tween.kill()
	sprite.modulate = Color(3, 3, 3)
	flash_tween = create_tween()
	flash_tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

func die() -> void:
	get_tree().call_group("camera", "add_trauma", 0.2)
	died.emit(self)
	queue_free()
