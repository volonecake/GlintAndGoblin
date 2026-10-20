class_name Projectile
extends Area2D

@export var damage: int = 1
@export var lifetime: float = 3.0

var velocity := Vector2.ZERO

func _ready() -> void:
	body_entered.connect(_on_hit)
	area_entered.connect(_on_hit)

func _physics_process(delta: float) -> void:
	position += velocity * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()

func _on_hit(other: Node) -> void:
	if other.has_method("take_damage"):
		other.take_damage(damage, global_position)
		get_tree().call_group("camera", "add_trauma", 0.1)
	queue_free()
