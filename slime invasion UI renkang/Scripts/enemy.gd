extends Area2D

@export var slime_speed: float = -100

var is_dead: bool = false


func _physics_process(delta: float) -> void:
	var game = get_tree().current_scene

	if not game.game_started:
		return

	if game.game_finished:
		return

	if not is_dead:
		position += Vector2(slime_speed, 0) * delta


func _on_body_entered(body: Node2D) -> void:
	var game = get_tree().current_scene

	if game.game_finished:
		return

	if body is CharacterBody2D and not is_dead:
		body.game_over()


func _on_area_entered(area: Area2D) -> void:
	var game = get_tree().current_scene

	if game.game_finished:
		return

	if area.is_in_group("bullet") and not is_dead:
		is_dead = true
		$AnimatedSprite2D.play("death")
		area.queue_free()
		game.score += 1
		$DeathSound.play()
		await get_tree().create_timer(0.6).timeout
		queue_free()
