class_name HeartsDisplay
extends HBoxContainer

@export var full_texture: Texture2D
@export var half_texture: Texture2D
@export var empty_texture: Texture2D
@export var heart_size := Vector2(32, 32)   # on-screen size of each heart

var hearts: Array[TextureRect] = []
var last_health := -1

func set_health(current: int, maximum: int) -> void:
	var count := ceili(maximum / 2.0)

	# add or remove hearts if max health changed
	while hearts.size() < count:
		var heart := TextureRect.new()
		heart.custom_minimum_size = heart_size
		heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		heart.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		heart.pivot_offset = heart_size / 2.0
		add_child(heart)
		hearts.append(heart)
	while hearts.size() > count:
		hearts.pop_back().queue_free()

	for i in hearts.size():
		var value := current - i * 2   # HP this heart is responsible for
		var tex := empty_texture
		if value >= 2:
			tex = full_texture
		elif value == 1:
			tex = half_texture


		if hearts[i].texture != tex and last_health != -1:
			_pop(hearts[i])
		hearts[i].texture = tex

	last_health = current

func _pop(heart: TextureRect) -> void:
	heart.scale = Vector2(1.5, 1.5)
	create_tween().tween_property(heart, "scale", Vector2.ONE, 0.2) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
