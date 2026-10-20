class_name GameCamera
extends Camera2D

@export_group("Look Ahead")
@export var look_ahead: float = 0.15          
@export var max_look_distance: float = 48.0   

@export_group("Shake")
@export var shake_decay: float = 2.5          
@export var max_shake: float = 6.0            

var trauma := 0.0
var look_offset := Vector2.ZERO

func _ready() -> void:
	add_to_group("camera")
	make_current()

func _process(delta: float) -> void:
	var to_mouse := get_viewport().get_mouse_position() - get_viewport_rect().size / 2.0
	var target_look := (to_mouse * look_ahead).limit_length(max_look_distance)
	look_offset = look_offset.lerp(target_look, 1.0 - exp(-8.0 * delta))

	trauma = maxf(trauma - shake_decay * delta, 0.0)
	var shake := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * max_shake * trauma * trauma

	offset = (look_offset + shake).round()

func add_trauma(amount: float) -> void:
	trauma = minf(trauma + amount, 1.0)

func set_limits(rect: Rect2i) -> void:
	limit_left = rect.position.x
	limit_top = rect.position.y
	limit_right = rect.end.x
	limit_bottom = rect.end.y
