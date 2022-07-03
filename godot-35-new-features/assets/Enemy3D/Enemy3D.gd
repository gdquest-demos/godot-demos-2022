extends KinematicBody
class_name Enemy3D

export var speed := 6.0
export var drag := 14.0
export var snap_length := 0.05
export var jump_force := 6.0
export var rotation_speed := 8.0

# ANCHOR: target
var _target: Player3D = null
# END: target
var _velocity := Vector3.ZERO
var _y_velocity: float
var _snap := Vector3.DOWN * snap_length

onready var _model: Spatial = $Model
onready var _blocked_check_raycast: RayCast = $Model/RayCast
onready var _detection_area: Area = $DetectionArea
onready var _hit_box: Area = $HitBox
onready var _gravity: float = -ProjectSettings.get_setting("physics/3d/default_gravity")

onready var _body_highlight: MeshInstance = $Model/RobotSkin/enemy_body/outline
onready var _track_left_highlight: MeshInstance = $Model/RobotSkin/enemy_track_left/outline
onready var _track_right_highlight: MeshInstance = $Model/RobotSkin/enemy_track_right/outline

onready var _animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	_detection_area.connect("body_entered", self, "_on_DetectionArea_body_entered")
	_detection_area.connect("body_exited", self, "_on_DetectionArea_body_exited")
	_hit_box.connect("body_entered", self, "_on_HitBox_body_entered")


# ANCHOR: processing
func _physics_process(delta: float) -> void:
	var desired_velocity := Vector3.ZERO
	var direction := _velocity.normalized()

	if _target:
		direction = global_transform.origin.direction_to(_target.global_transform.origin)
		direction.y = 0.0
		direction = direction.normalized()
		desired_velocity = direction * speed
		_orient_character_to_direction(direction, delta)

	_y_velocity = _velocity.y
	_velocity.y = 0.0

	if is_on_floor():
		_y_velocity = 0.0
	else:
		_y_velocity += _gravity * delta

	if _blocked_check_raycast.is_colliding() and is_on_floor():
		_y_velocity = jump_force

	var steering := desired_velocity - _velocity
	_velocity += steering / drag

	_velocity.y = _y_velocity
	_velocity = move_and_slide_with_snap(_velocity, _snap, Vector3.UP, true)
# END: processing


func _orient_character_to_direction(direction: Vector3, delta: float) -> void:
	# Since we want the model's -z axis to be used as forward as is standard in Godot
	# we need to negate direction
	var left_axis := Vector3.UP.cross(-direction)
	var rotation_basis := Basis(left_axis, Vector3.UP, -direction)
	_model.transform.basis = _model.transform.basis.slerp(rotation_basis, delta * rotation_speed)

# ANCHOR: body_entered_exited
func _on_DetectionArea_body_entered(body: Node) -> void:
	if body is Player3D:
		_target = body


func _on_DetectionArea_body_exited(body: Node) -> void:
	if body is Player3D:
		_target = null
# END: body_entered_exited


func _on_HitBox_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage()

func highlight() -> void:
	_animation_player.play("highlight")
	_animation_player.seek(0, true)
