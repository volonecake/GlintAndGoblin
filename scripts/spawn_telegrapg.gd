class_name SpawnTelegraph
extends Node2D

signal finished

@export var duration := 0.6
@export var radius := 14.0
@export var color := Color(1.0, 0.3, 0.3)

var t := 0.0

func _process(delta: float) -> void:
	t += delta
	queue_redraw()
	if t >= duration:
		finished.emit()
		queue_free()

func _draw() -> void:
	var p := clampf(t / duration, 0.0, 1.0)
	# ring shrinks inward with a  circle growing and becomes brighter (actually help i think im tweaking)
	draw_arc(Vector2.ZERO, radius * (1.3 - 0.5 * p), 0.0, TAU, 24, Color(color, 0.4 + 0.6 * p), 2.0)
	draw_circle(Vector2.ZERO, radius * p * 0.8, Color(color, 0.25))
