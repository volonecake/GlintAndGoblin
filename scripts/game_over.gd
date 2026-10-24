extends CanvasLayer

const MENU_SCENE := "res://scenes/MainMenu.tscn"

@onready var result_label: Label = $Center/VBox/ResultLabel
@onready var best_label: Label = $Center/VBox/BestLabel
@onready var retry_button: Button = $Center/VBox/RetryButton
@onready var menu_button: Button = $Center/VBox/MenuButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	retry_button.pressed.connect(func():
		get_tree().paused = false
		get_tree().reload_current_scene())
	menu_button.pressed.connect(func():
		get_tree().paused = false
		get_tree().change_scene_to_file(MENU_SCENE))

func show_results(wave: int, best: int, is_new_best: bool) -> void:
	result_label.text = "You reached wave %d" % wave
	best_label.text = "NEW BEST!" if is_new_best else "Best: wave %d" % best
	show()
	get_tree().paused = true
	retry_button.grab_focus()
