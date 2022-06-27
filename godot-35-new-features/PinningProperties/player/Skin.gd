extends Sprite

const SPRITES_MAP := {
	Vector2.RIGHT: preload("godot_right.png"),
	Vector2.DOWN: preload("godot_bottom.png"),
	Vector2.LEFT: preload("godot_right.png"),
	Vector2.UP: preload("godot_up.png"),
	Vector2(1.0, 1.0): preload("godot_bottom_right.png"),
	Vector2(1.0, -1.0): preload("godot_up_right.png"),
	Vector2(-1.0, -1.0): preload("godot_up_right.png"),
	Vector2(-1.0, 1.0): preload("godot_bottom_right.png"),
}

var look_direction := Vector2.RIGHT


func _process(delta: float) -> void:
	var input_vector := Vector2(
		float(Input.is_action_pressed("ui_right")) - float(Input.is_action_pressed("ui_left")),
		float(Input.is_action_pressed("ui_down")) - float(Input.is_action_pressed("ui_up"))
	)
	
	if input_vector.length() > 0.0 and input_vector != look_direction:
		texture = SPRITES_MAP[input_vector]
		look_direction = input_vector
		flip_h = sign(look_direction.x) == -1.0

	position.y = sin(OS.get_ticks_msec() / 200.0) * 8.0
