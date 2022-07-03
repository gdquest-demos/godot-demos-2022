extends KinematicBody

export var player_path: NodePath

export var max_speed := 2.0
export var rotation_speed := 8.0

var _velocity := Vector3.ZERO
var _snap := Vector3.DOWN * 0.05

onready var _model: Spatial = $Model
onready var _timer: Timer = $Timer
onready var _player := get_node(player_path) as Player3D

onready var _agent: NavigationAgent = $NavigationAgent


func _ready() -> void:
	_timer.connect("timeout", self, "_update_pathfinding")
	_agent.connect("velocity_computed", self, "_move")


func _physics_process(delta: float) -> void:
	if _agent.is_navigation_finished():
		return

	var target_global_position := _agent.get_next_location()
	var direction := global_transform.origin.direction_to(target_global_position)
	var desired_velocity := direction * _agent.max_speed
	var steering := (desired_velocity - _velocity) * delta * 4.0
	_velocity += steering
	_agent.set_velocity(_velocity)


func _move(velocity: Vector3) -> void:
	_velocity = move_and_slide_with_snap(velocity, _snap, Vector3.UP, true)
	var direction := Vector3(velocity.x, 0, velocity.z).normalized()
	_orient_character_to_direction(direction)


func _orient_character_to_direction(direction: Vector3) -> void:
	var left_axis := Vector3.UP.cross(direction)
	var rotation_basis := Basis(left_axis, Vector3.UP, direction)
	_model.transform.basis = _model.transform.basis.slerp(rotation_basis, get_physics_process_delta_time() * rotation_speed)


func _update_pathfinding() -> void:
	_agent.set_target_location(_player.global_transform.origin)
