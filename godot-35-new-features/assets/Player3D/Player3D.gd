class_name Player3D
extends KinematicBody

export var move_speed := 6.0
export var acceleration := 4.0
export var jump_initial_impulse := 12.0
export var jump_additional_force := 4.5
export var rotation_speed := 12.0
export var snap_length := 0.5
export var do_stop_on_slope := true
export var has_infinite_inertia := true
export var camera_path: NodePath

var velocity: Vector3
var is_healing := false setget set_is_healing

var _move_direction := Vector3.ZERO
var _last_strong_direction := Vector3.FORWARD
var _snap := Vector3.DOWN * snap_length
var _gravity: float = -30.0
var _camera_controller: Spatial

onready var _model: AstronautSkin = $AstronautSkin
onready var _start_position := global_transform.origin
onready var _hit_box_collision: CollisionShape = $AttackHitBox/CollisionShape
onready var _label_3d: Label3D = get_node_or_null("Label3D")

func _ready() -> void:
	_camera_controller = get_node(camera_path)
	_model.max_ground_speed = move_speed
	_model.connect("attack_finished", _hit_box_collision, "set_deferred", ["disabled", true])
	if _label_3d:
		_label_3d.scale = Vector3.ZERO

func _physics_process(delta: float) -> void:
	_move_direction = _get_camera_oriented_input()

	# To not orient quickly to the last input, we save a last strong direction,
	# this also ensures a good normalized value for the rotation basis.
	if _move_direction.length() > 0.2:
		_last_strong_direction = _move_direction.normalized()

	_orient_character_to_direction(_last_strong_direction, delta)

	# We separate out the y velocity to not interpolate on the gravity
	var y_velocity = velocity.y
	velocity.y = 0.0
	velocity = velocity.linear_interpolate(_move_direction * move_speed, acceleration * delta)
	velocity.y = y_velocity

	if is_on_floor():
		velocity.y = 0.0
	else:
		velocity.y += _gravity * delta

	if is_jumping():
		velocity.y = jump_initial_impulse
		_snap = Vector3.ZERO
		_model.jump()
	elif is_air_boosting():
		velocity.y += jump_additional_force * delta
	elif is_landing():
		_snap = Vector3.DOWN * snap_length
		_model.land()

	velocity = move_and_slide_with_snap(
		velocity, _snap, Vector3.UP, do_stop_on_slope, 4, deg2rad(45), has_infinite_inertia
	)
	_model.velocity = velocity


func _get_camera_oriented_input() -> Vector3:
	var input_left_right := (
		Input.get_action_strength("ui_right")
		- Input.get_action_strength("ui_left")
	)
	var input_forward_back := (
		Input.get_action_strength("ui_down")
		- Input.get_action_strength("ui_up")
	)
	var raw_input = Vector2(input_left_right, input_forward_back)

	var input := Vector3.ZERO
	# This is to ensure that diagonal input isn't stronger than axis aligned input
	input.x = raw_input.x * sqrt(1.0 - raw_input.y * raw_input.y / 2.0)
	input.z = raw_input.y * sqrt(1.0 - raw_input.x * raw_input.x / 2.0)

	input = _camera_controller.global_transform.basis.xform(input)
	return input


func _orient_character_to_direction(direction: Vector3, delta: float) -> void:
	var left_axis := Vector3.UP.cross(direction)
	var rotation_basis := Basis(left_axis, Vector3.UP, direction).get_rotation_quat()
	var model_scale := _model.transform.basis.get_scale()
	_model.transform.basis = Basis(_model.transform.basis.get_rotation_quat().slerp(rotation_basis, delta * rotation_speed)).scaled(
		model_scale
	)


# ANCHOR: attack
func attack() -> void:
	_model.attack()
	_hit_box_collision.set_deferred("disabled", false)
	yield(_model.anim_player, "animation_finished")
	_hit_box_collision.set_deferred("disabled", true)
# END: attack


func is_jumping() -> bool:
	return Input.is_action_just_pressed("ui_accept") and is_on_floor()


func is_air_boosting() -> bool:
	return Input.is_action_pressed("ui_accept") and not is_on_floor() and velocity.y > 0.0


func is_landing() -> bool:
	return _snap == Vector3.ZERO and is_on_floor()


func reset_position() -> void:
	transform.origin = _start_position


func set_is_healing(is_it: bool) -> void:
	if is_it == is_healing:
		return
	is_healing = is_it
	
	if not _label_3d:
		return
	
	# THERE ARE CHARACTERS HERE, DO NOT DELETE
	# these aren't empty strings, they're characters from a custom icon font
	# created on Fontello. Godot's editor doesn't show them, but they're there
	_label_3d.text = ["", "", ""][randi() % 3]
	
	create_tween()\
		.set_trans(Tween.TRANS_ELASTIC)\
		.set_ease(Tween.EASE_OUT)\
		.tween_property(
			_label_3d, 
			"scale", 
			Vector3.ONE if is_it else Vector3.ZERO,
			1.0
		)
