extends KinematicBody

# Number of frames we wait for between two updates of the navigation paths.
# Physics processing runs 60 times per second by default, so that's 6 updates per second.
# Doing this can greatly improve performance.

const FRAMES_BETWEEN_UPDATES := 10

export var player_path: NodePath

export var move_speed := 2.0
export var acceleration := 14.0
export var snap_length := 0.05
export var rotation_speed := 8.0
export var stopping_distance := 0.1
export var path_tolerance := 0.05

var _velocity := Vector3.ZERO
var _snap := Vector3.DOWN * snap_length
var _frame_counter = 0

onready var _model: Spatial = $Model
onready var _navigation_agent: NavigationAgent = $NavigationAgent
onready var _player: Player3D = get_node(player_path) as Player3D


func _ready() -> void:
	_navigation_agent.connect("velocity_computed", self, "_on_velocity_computed")


func _physics_process(delta: float) -> void:
	if _frame_counter == 0:
		# We attempt to get a path from the enemy to the player.
		_navigation_agent.set_target_location(_player.global_translation)
		
	_frame_counter = wrapi(_frame_counter + 1, 0, FRAMES_BETWEEN_UPDATES)

	var next_location = _navigation_agent.get_next_location()
	var direction: Vector3 = next_location - global_translation

	direction.y = 0.0
	direction = direction.normalized()

	if direction != Vector3.ZERO:
		_orient_character_to_direction(direction, delta)

	var final_destination := _navigation_agent.get_final_location()
#
	if global_translation.distance_squared_to(final_destination) > stopping_distance:
		_velocity = _velocity.linear_interpolate(direction * move_speed, acceleration * delta)
		_navigation_agent.set_velocity(_velocity)


func _on_velocity_computed(vel) -> void:
	_velocity = move_and_slide_with_snap(vel, _snap, Vector3.UP, true)


func _orient_character_to_direction(direction: Vector3, delta: float) -> void:
	var left_axis := Vector3.UP.cross(direction)
	var rotation_basis := Basis(left_axis, Vector3.UP, direction)
	_model.transform.basis = _model.transform.basis.slerp(rotation_basis, delta * rotation_speed)
