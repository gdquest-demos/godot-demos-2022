extends KinematicBody

# Number of frames we wait for between two updates of the navigation paths.
# Physics processing runs 60 times per second by default, so that's 6 updates per second.
# Doing this can greatly improve performance.
# ANCHOR: const
const FRAMES_BETWEEN_UPDATES := 10
# END: const

export var navigation_path: NodePath
export var player_path: NodePath

export var move_speed := 2.0
export var acceleration := 14.0
export var snap_length := 0.05
export var rotation_speed := 8.0
export var stopping_distance := 0.1
export var path_tolerance := 0.05

var _path: PoolVector3Array
var _velocity := Vector3.ZERO
var _snap := Vector3.DOWN * snap_length
var _frame_counter = 0

# ANCHOR: onready
onready var _model: Spatial = $Model
onready var _navigation: Navigation = get_node(navigation_path) as Navigation
onready var _player: Player3D = get_node(player_path) as Player3D
# END: onready


func _physics_process(delta: float) -> void:
	# ANCHOR: get_path
	if _frame_counter == 0:
		# We attempt to get a path from the enemy to the player.
		var potential_path = _navigation.get_simple_path(
			global_transform.origin, _player.global_transform.origin
		)
		# If the path array we get back is larger than 0 it's a valid path
		# and we assign it otherwise we stick to the old path.
		if potential_path.size() > 0:
			_path = potential_path
	_frame_counter = wrapi(_frame_counter + 1, 0, FRAMES_BETWEEN_UPDATES)
	# END: get_path

	# ANCHOR: update_path
	var position_on_navigation_mesh = _navigation.get_closest_point(global_transform.origin)

	if not _path.size():
		return
	# When we get close to the next point on the path, we remove that point
	if (
		position_on_navigation_mesh.distance_squared_to(_path[0]) < path_tolerance
		and _path.size() > 1
	):
		_path.remove(0)
	# END: update_path

	# ANCHOR: direction
	var direction: Vector3 = _path[0] - position_on_navigation_mesh

	direction.y = 0.0
	direction = direction.normalized()

	_orient_character_to_direction(direction, delta)
	# END: direction

	# ANCHOR: move
	var final_destination := _path[_path.size() - 1]

	if position_on_navigation_mesh.distance_squared_to(final_destination) > stopping_distance:
		_velocity = _velocity.linear_interpolate(direction * move_speed, acceleration * delta)
		_velocity = move_and_slide_with_snap(_velocity, _snap, Vector3.UP, true)
	# END: move


# ANCHOR: orient_character
func _orient_character_to_direction(direction: Vector3, delta: float) -> void:
	var left_axis := Vector3.UP.cross(direction)
	var rotation_basis := Basis(left_axis, Vector3.UP, direction)
	_model.transform.basis = _model.transform.basis.slerp(rotation_basis, delta * rotation_speed)
# END: orient_character
