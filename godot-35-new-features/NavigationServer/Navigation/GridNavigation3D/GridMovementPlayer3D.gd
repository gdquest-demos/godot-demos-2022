extends KinematicBody

export var navigation_path: NodePath
export var camera_path: NodePath

export var move_speed := 6.0
export var acceleration := 14.0
export var snap_length := 0.5
export var rotation_speed := 8.0
export var stopping_distance := 0.1
export var path_tolerance := 0.05

var _path: PoolVector3Array
var _velocity := Vector3.ZERO
var _snap := Vector3.DOWN * snap_length
var _gravity: float = -1.0

onready var _model: AstronautSkin = $AstronautSkin
onready var _navigation: Navigation = get_node(navigation_path) as Navigation
onready var _camera: Camera = get_node(camera_path) as Camera


func _ready() -> void:
	_model.max_ground_speed = move_speed
	set_physics_process(false)


# ANCHOR: set_destination
func set_destination(position: Vector3):
	_path = _navigation.get_simple_path(global_transform.origin, position)
	set_physics_process(true)
# END: set_destination


# ANCHOR: process
func _physics_process(delta: float) -> void:
	var position_on_navigation_mesh = _navigation.get_closest_point(global_transform.origin)
	var final_destination := _path[_path.size() - 1]

	if (
		position_on_navigation_mesh.distance_squared_to(_path[0]) < path_tolerance
		and _path.size() > 1
	):
		_path.remove(0)

	var direction: Vector3 = _path[0] - position_on_navigation_mesh

	direction.y = 0.0
	direction = direction.normalized()
	_orient_character_to_direction(direction, delta)

	_velocity = _velocity.linear_interpolate(direction * move_speed, acceleration * delta)
	_velocity = move_and_slide_with_snap(_velocity, _snap, Vector3.UP, true, 4, deg2rad(60))
# END: process
	_model.velocity = _velocity

	if position_on_navigation_mesh.distance_squared_to(final_destination) < stopping_distance:
		_model.velocity = Vector3.ZERO
		set_physics_process(false)


func _orient_character_to_direction(direction: Vector3, delta: float) -> void:
	var left_axis := Vector3.UP.cross(direction)
	var rotation_basis := Basis(left_axis, Vector3.UP, direction).get_rotation_quat()
	var model_scale := _model.transform.basis.get_scale()
	_model.transform.basis = Basis(_model.transform.basis.get_rotation_quat().slerp(rotation_basis, delta * rotation_speed)).scaled(
		model_scale
	)
