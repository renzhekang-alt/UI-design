extends CharacterBody2D

@export var move_speed: float = 50
@export var animator: AnimatedSprite2D
@export var is_game_over: bool = false
@export var bullet_scene: PackedScene


func _process(delta: float) -> void:
	var game = get_tree().current_scene

	if not game.game_started or game.game_finished:
		$RunningSound.stop()
		return

	if velocity == Vector2.ZERO or is_game_over:
		$RunningSound.stop()
	elif not $RunningSound.playing:
		$RunningSound.play()

	if not is_game_over and Input.is_action_just_pressed("fire"):
		_on_fire()


func _physics_process(delta: float) -> void:
	var game = get_tree().current_scene

	if not game.game_started or game.game_finished:
		velocity = Vector2.ZERO
		return

	if not is_game_over:
		velocity = Input.get_vector("left", "right", "up", "down") * move_speed

		if velocity == Vector2.ZERO:
			animator.play("idle")
		else:
			animator.play("run")

		move_and_slide()


func game_over() -> void:
	if not is_game_over:
		is_game_over = true
		animator.play("game_over")
		get_tree().current_scene.show_game_over()
		$GameOverSound.play()
		$RestartTimer.start()


func _on_fire() -> void:
	var game = get_tree().current_scene

	if not game.game_started or game.game_finished:
		return

	if velocity != Vector2.ZERO or is_game_over:
		return

	$FireSound.play()

	var bullet_node = bullet_scene.instantiate()
	bullet_node.position = position + Vector2(6, 6)
	get_tree().current_scene.add_child(bullet_node)


func _reload_scene() -> void:
	get_tree().reload_current_scene()
