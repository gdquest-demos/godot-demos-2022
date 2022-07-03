extends Spatial

export(NodePath) var player_path : NodePath
export(float, 0.0, 1.0) var mouse_sensitivity := 0.25
export(float, 0.0, 8.0) var joystick_sensitivity := 2.0
export(float, -90, 0.0) var tilt_upper_limit := -60.0
export(float, 0.0, 90.0) var tilt_lower_limit := 60.0

var _rotation_input: float
var _tilt_input: float
var _mouse_input := false
var _offset: Vector3

onready var _parent: Spatial = get_parent()
onready var _tilt_pivot: Spatial = get_node("CameraTiltPivot")


func _ready() -> void:
	set_as_toplevel(true)
	_offset = global_transform.origin - _parent.global_transform.origin


func _unhandled_input(event: InputEvent) -> void:
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input:
		_rotation_input = -event.relative.x * mouse_sensitivity
		_tilt_input = -event.relative.y * mouse_sensitivity
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(
			(
				Input.MOUSE_MODE_VISIBLE
				if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
				else Input.MOUSE_MODE_CAPTURED
			)
		)

func _process(delta: float) -> void:
	global_transform.origin = _parent.global_transform.origin + _offset

	_rotation_input += Input.get_action_strength("camera_left") - Input.get_action_strength("camera_right")
	_tilt_input += Input.get_action_strength("camera_up") - Input.get_action_strength("camera_down")

	if not _mouse_input:
		_rotation_input *= joystick_sensitivity
		_tilt_input *= joystick_sensitivity

	rotate_y(_rotation_input * delta)
	_tilt_pivot.rotate_x(_tilt_input * delta)
	_tilt_pivot.rotation_degrees.x = clamp(_tilt_pivot.rotation_degrees.x, tilt_upper_limit, tilt_lower_limit)

	_rotation_input = 0.0
	_tilt_input = 0.0
