extends CanvasLayer

const MENU_SCENE := "res://scenes/MainMenu.tscn"

@onready var resume_button: Button = $Continue
@onready var menu_button: Button = $Quit

var can_pause := true

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS   # keeps working while the tree is paused
	hide()
	resume_button.pressed.connect(func(): _set_paused(false))
	menu_button.pressed.connect(_to_menu)

func _unhandled_input(event: InputEvent) -> void:
	if can_pause and event.is_action_pressed("pause"):
		_set_paused(not get_tree().paused)
		get_viewport().set_input_as_handled()

func _set_paused(value: bool) -> void:
	get_tree().paused = value
	visible = value
	if value:
		resume_button.grab_focus()

func _to_menu() -> void:
	get_tree().paused = false   # always unpause before changing scenes
	get_tree().change_scene_to_file(MENU_SCENE)
