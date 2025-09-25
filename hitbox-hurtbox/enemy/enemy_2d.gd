extends Node2D

@onready var _hp_progress_bar: ProgressBar = %HPProgressBar
@onready var _animation_player: AnimationPlayer = %AnimationPlayer


func take_damage(amount: int) -> void:
	_hp_progress_bar.value = max(0, _hp_progress_bar.value - amount)
	if _hp_progress_bar.value == 0:
		queue_free()
	_animation_player.play("hit")
