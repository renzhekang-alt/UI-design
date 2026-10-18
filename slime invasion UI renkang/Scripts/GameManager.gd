
extends Node2D

@export var slime_scene: PackedScene
@export var spawn_timer: Timer
@export var score: int = 0
@export var score_label: Label
@export var game_over_label: Label
@export var win_score: int = 100

var game_started: bool = false
var game_finished: bool = false
var is_paused: bool = false

@onready var quest_log = $CanvasLayer/QuestLog
@onready var pause_menu = $CanvasLayer/PauseMenu
@onready var resume_button = $CanvasLayer/PauseMenu/MarginContainer/VBoxContainer/ResumeButton


func _ready() -> void:
	get_tree().paused = false
	spawn_timer.stop()
	$CanvasLayer/startscreen.show()
	$CanvasLayer/Victory.hide()
	$CanvasLayer/VillageGameOver.hide()
	game_over_label.hide()
	quest_log.hide()
	pause_menu.hide()
	pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS


func _process(delta: float) -> void:
	if game_started and not game_finished:
		spawn_timer.wait_time -= 0.2 * delta
		spawn_timer.wait_time = clamp(spawn_timer.wait_time, 1.0, 3.0)

	score_label.text = "Slimes Defeated: " + str(score) + " / " + str(win_score)

	if score >= win_score and not game_finished:
		show_victory()


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return

	if not event.pressed or event.echo:
		return

	if event.keycode == KEY_ESCAPE and game_started and not game_finished:
		toggle_pause()
		get_viewport().set_input_as_handled()

	elif event.keycode == KEY_Q and game_started and not game_finished and not is_paused:
		quest_log.visible = not quest_log.visible
		get_viewport().set_input_as_handled()


func toggle_pause() -> void:
	if is_paused:
		resume_game()
	else:
		pause_game()


func pause_game() -> void:
	is_paused = true
	quest_log.hide()
	pause_menu.show()
	get_tree().paused = true
	resume_button.grab_focus()


func resume_game() -> void:
	get_tree().paused = false
	is_paused = false
	pause_menu.hide()
	resume_button.release_focus()


func _spawn_slime() -> void:
	if not game_started or game_finished:
		return

	var slime_node = slime_scene.instantiate()
	slime_node.position = Vector2(260, randf_range(50, 115))
	add_child(slime_node)


func show_game_over() -> void:
	if game_finished:
		return

	game_finished = true
	game_started = false
	spawn_timer.stop()
	game_over_label.show()


func show_village_game_over() -> void:
	if game_finished:
		return

	game_finished = true
	game_started = false
	spawn_timer.stop()
	$CanvasLayer/VillageGameOver.show()
	$Player/GameOverSound.play()


func show_victory() -> void:
	if game_finished:
		return

	game_finished = true
	game_started = false
	spawn_timer.stop()
	$CanvasLayer/Victory.show()


func _on_start_button_pressed() -> void:
	$CanvasLayer/startscreen.hide()
	game_started = true
	game_finished = false
	spawn_timer.start()


func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_resume_button_pressed() -> void:
	resume_game()


func _on_pause_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_village_line_area_entered(
	area_rid: RID,
	area: Area2D,
	area_shape_index: int,
	local_shape_index: int
) -> void:
	if area.is_in_group("enemy") and not game_finished:
		show_village_game_over()
