extends Node2D

const STEP := 80
const SPEED := 888

onready var _animation_player: AnimationPlayer = $Crosshair/AnimationPlayer
onready var _path_follow: PathFollow2D = $Path2D/PathFollow2D
onready var _ship: Node2D = $Path2D/PathFollow2D/Ship
onready var _navigator: Navigation2D = $Navigation2D
onready var _target: Node2D = $Crosshair
onready var _halo := $HaloCircle
onready var _path: Path2D = $Path2D
onready var _tween: Tween = $Tween


func _unhandled_input(event: InputEvent) -> void:
	# When moving the mouse, we update the target, which we use to move the crosshair sprite.
	if event is InputEventMouseMotion:
		var new_target := stepify_vector(get_local_mouse_position(), STEP)
		_target.position = _navigator.get_closest_point(new_target)
	# And when the player clicks, we move to the target position.
	if event.is_action_pressed("click") and not _animation_player.is_playing():
		move_ship_to_click(_target.position)
		animate_selection(_target.position)


# ANCHOR: move_ship_to_click
func move_ship_to_click(target_position: Vector2) -> void:
	# We use Path2D and PathFollow2D nodes to make the ship move along the navigation path.
	# This makes it easy to do navigation; all we have to do is feed the navigation path
	# to the Path2D node's `curve`.
	_path.curve.clear_points()
	for point in _navigator.get_simple_path(_path_follow.position, target_position):
		_path.curve.add_point(point)
	# Animating the offset or unit_offset property of PathFollow2D makes the ship move along
	# the parent Path2D node.
	_tween.interpolate_property(
		_path_follow, "unit_offset", 0.0, 1.0, _path.curve.get_baked_length() / SPEED
	)
	_tween.start()
# END: move_ship_to_click


func animate_selection(target_position: Vector2) -> void:
	_animation_player.play("Click")
	_halo.position = target_position
	_tween.interpolate_property(_halo, "size", 0, 100, 1.0)
	_tween.interpolate_property(_halo, "modulate", Color.white, Color.transparent, 1.0)
	_tween.start()


# ANCHOR: stepify
## Rounds each component of the vector to the `step` value.
func stepify_vector(vector_in: Vector2, step: float) -> Vector2:
	return Vector2(stepify(vector_in.x, step), stepify(vector_in.y, step))
# END: stepify
