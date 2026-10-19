extends CharacterBody2D

@export var speed: float = 120.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(_delta: float) -> void:
	# get_vector normalizes diagonals, avoids player moving faster when moving diagonally
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = dir * speed
	move_and_slide()
	_update_animation(dir)

func _update_animation(dir: Vector2) -> void:
	if dir == Vector2.ZERO:
		sprite.play("idle")
		return

	# picks the main axis so it still shows an animation that would make sense (not playing up anim when moving to the right more ykwim?)
	if absf(dir.x) > absf(dir.y):
		sprite.play("walk_east" if dir.x > 0 else "walk_west")
	else:
		sprite.play("walk_down" if dir.y > 0 else "walk_up")
