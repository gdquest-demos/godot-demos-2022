class_name AstronautSkin
extends Spatial

signal mantle_finished
signal attack_finished

export var auto_fall := true
const MOVE_SPEED_THRESHOLD := 0.6
const LEDGE_MOVE_SPEED_THRESHOLD := 0.1
const IDLE_BREAK_WAIT_TIME := 7.0
const LEDGE_OFFSET := Vector3.UP * 1.28 + Vector3.BACK * 0.4
const MANTLE_DURATION := 0.9

const ROOT_BONE_INDEX := 1
# The model coming from Akeytsu, converted from FBX to GLTF on sketchfab, has
# two scaled nodes. We use this to scale the root motion or offset the character
# after playing an animation with root animation.
const MODEL_SCALE := 0.01

var velocity := Vector3.ZERO setget set_velocity
var max_ground_speed := -1.0 setget set_max_ground_speed
var max_ledge_speed := -1.0 setget set_max_ledge_speed
# ANCHOR: set_on_ledge
var is_on_ledge := false setget set_is_on_ledge
# END: set_on_ledge
var is_pushing := false setget set_is_pushing
var move_horizontal_direction := 0.0 setget set_move_horizontal_direction

var _max_ground_speed_squared := -1.0
var _max_ledge_speed_squared := -1.0
var _is_idle := false setget _set_is_idle
var _idle_break_timer := Timer.new()

onready var anim_player: AnimationPlayer = $AnimationPlayer

onready var _tree: AnimationTree = $AnimationTree
onready var _playback: AnimationNodeStateMachinePlayback = _tree["parameters/playback"]
onready var _skeleton: Skeleton = $"Sketchfab_model/033f197b533a4ee2a426dde7801e0435fbx/Object_2/RootNode/Object_4/Skeleton"


func _ready() -> void:
	_tree.active = true
	add_child(_idle_break_timer)
	_idle_break_timer.wait_time = IDLE_BREAK_WAIT_TIME
	_idle_break_timer.one_shot = true
	_idle_break_timer.connect("timeout", _playback, "travel", ["idle_break"])
	anim_player.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")


func _physics_process(delta: float) -> void:
	var speed_squared := velocity.length_squared()
	var speed_ratio := speed_squared / _max_ground_speed_squared
	var is_moving := speed_squared >= MOVE_SPEED_THRESHOLD
	_set_is_idle(speed_squared <= MOVE_SPEED_THRESHOLD)
	_tree["parameters/conditions/is_moving"] = is_moving
	_tree["parameters/conditions/is_idle"] = _is_idle
	_tree["parameters/move/blend_position"] = speed_ratio
	var fall_list = ["move", "jump"] if auto_fall else ["jump"]
	if velocity.y < -0.1 and _playback.get_current_node() in fall_list:
		_playback.travel("fall")
	elif _playback.get_current_node() == "fall" and is_equal_approx(velocity.y, 0.0):
		_playback.travel("idle")


func set_velocity(new_velocity: Vector3) -> void:
	velocity = new_velocity


func set_max_ground_speed(new_max_speed: float) -> void:
	max_ground_speed = new_max_speed
	_max_ground_speed_squared = max_ground_speed * max_ground_speed


func set_max_ledge_speed(new_max_speed: float) -> void:
	max_ledge_speed = new_max_speed
	_max_ledge_speed_squared = max_ledge_speed * max_ledge_speed

# ANCHOR: ledge_anim
func set_is_on_ledge(on_ledge: bool) -> void:
	var was_on_ledge := is_on_ledge
	is_on_ledge = on_ledge

	if on_ledge and not was_on_ledge:
		_playback.travel("ledge")
		_skeleton.clear_bones_global_pose_override()

	elif was_on_ledge and not on_ledge:
		_playback.travel("idle")
		# Only the ledge animations use root motion so we need to reset the
		# bone's position to its rest pose.
		_skeleton.set_bone_global_pose_override(ROOT_BONE_INDEX, Transform.IDENTITY, 1.0, true)
		transform.origin = Vector3.ZERO
# END: ledge_anim

func set_is_pushing(new_pushing_state: bool) -> void:
	if is_pushing and not new_pushing_state:
		_playback.travel("idle")
	elif not is_pushing and new_pushing_state:
		_playback.travel("push")
	is_pushing = new_pushing_state

func jump() -> void:
	_playback.travel("jump")


func land() -> void:
	if velocity.length_squared() > 0.0:
		_playback.travel("idle")
	else: 
		_playback.travel("move")


func attack() -> void:
	_playback.travel("attack")
	yield(get_tree().create_timer(0.5), "timeout")
	emit_signal("attack_finished")


func is_attacking() -> bool:
	return _playback.get_current_node() == "attack"

func is_falling() -> bool:
	return _playback.get_current_node() == "fall"

func _set_is_idle(new_value: bool) -> void:
	if not is_on_ledge:
		if new_value and not _is_idle:
			_idle_break_timer.start(IDLE_BREAK_WAIT_TIME)
		elif not new_value:
			_idle_break_timer.stop()
	_is_idle = new_value


func set_move_horizontal_direction(new_direction: float) -> void:
	move_horizontal_direction = new_direction
	var ledge_speed_ratio := velocity.length_squared() / _max_ledge_speed_squared
	_tree["parameters/ledge/move/blend_position"] = (
		ledge_speed_ratio
		* sign(move_horizontal_direction)
	)


func _on_AnimationPlayer_animation_finished(animation_name: String) -> void:
	# We restart the idle break timer if the break ends. Leaving the idle state will stop the timer.
	if animation_name == "IDLE_BREAK":
		_idle_break_timer.stop()
		_idle_break_timer.start(IDLE_BREAK_WAIT_TIME * 2.0)
