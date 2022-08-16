extends Sprite

var tween: SceneTreeTween


func _unhandled_input(event: InputEvent) -> void:
	if tween and tween.is_running():
		return

	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		move_to_mouse()


func move_to_mouse() -> void:
	if tween:
		tween.kill()

	tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_position", get_global_mouse_position(), 0.5)

	rotation = global_position.direction_to(get_global_mouse_position()).angle() + PI / 2.0
