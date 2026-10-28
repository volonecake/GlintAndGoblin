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

	var outer := radius * (1.3 - 0.5 * p)
	var outline := Rect2(Vector2(-outer, -outer), Vector2(outer, outer) * 2.0)
	draw_rect(outline, Color(color, 0.4 + 0.6 * p), false, 2.0)

	var inner := radius * p * 0.8
	var fill := Rect2(Vector2(-inner, -inner), Vector2(inner, inner) * 2.0)
	draw_rect(fill, Color(color, 0.25))
