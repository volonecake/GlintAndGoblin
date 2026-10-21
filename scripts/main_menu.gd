extends Control

const ARENA_SCENE := "res://scenes/main.tscn"
const FADE_TIME := 0.35

@onready var main_panel: Control
@onready var mode_panel: Control = $ModePanel
@onready var quit_panel: Control = $QuitPanel
@onready var fade: ColorRect = $Fade

@onready var start_button: Button = $StartButton
@onready var options_button: Button = $OptionsButton
@onready var arena_button: Button = $ModePanel/VBox/ArenaButton
@onready var dungeon_button: Button = $ModePanel/VBox/DungeonButton
@onready var back_button: Button = $ModePanel/VBox/BackButton
@onready var quit_button: Button = $QuitPanel/VBox/QuitButton
@onready var cancel_button: Button = $QuitPanel/VBox/CancelButton

var busy := false   # blocks input while a fade is running

func _ready() -> void:
	fade.modulate.a = 0.0
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE

	start_button.pressed.connect(func(): _fade_to_panel(mode_panel, arena_button))
	options_button.pressed.connect(func(): _show_only(quit_panel, cancel_button))

	arena_button.pressed.connect(func(): _fade_to_scene(ARENA_SCENE))
	dungeon_button.disabled = true   # enable once dungeon mode exists
	back_button.pressed.connect(func(): _fade_to_panel(main_panel, start_button))

	quit_button.pressed.connect(get_tree().quit)
	cancel_button.pressed.connect(func(): _show_only(main_panel, start_button))
	if OS.has_feature("web"):
		quit_button.hide() 

	_show_only(main_panel, start_button)

func _unhandled_input(event: InputEvent) -> void:
	if busy or not event.is_action_pressed("ui_cancel"):
		return
	if mode_panel.visible:
		_fade_to_panel(main_panel, start_button)
	elif quit_panel.visible:
		_show_only(main_panel, start_button)

func _show_only(panel: Control, focus_target: Button) -> void:
	for p in [mode_panel, quit_panel]:
		p.visible = (p == panel)
	focus_target.grab_focus()

func _fade(to_alpha: float) -> void:
	var tw := create_tween()
	tw.tween_property(fade, "modulate:a", to_alpha, FADE_TIME)
	await tw.finished

func _fade_to_panel(panel: Control, focus_target: Button) -> void:
	if busy:
		return
	busy = true
	fade.mouse_filter = Control.MOUSE_FILTER_STOP   
	await _fade(1.0)
	_show_only(panel, focus_target)
	await _fade(0.0)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	busy = false

func _fade_to_scene(path: String) -> void:
	if busy:
		return
	busy = true
	fade.mouse_filter = Control.MOUSE_FILTER_STOP
	await _fade(1.0)
	get_tree().change_scene_to_file(path)
