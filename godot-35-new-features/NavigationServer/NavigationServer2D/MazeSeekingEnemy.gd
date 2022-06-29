extends Path2D
# ANCHOR: onready
const SPEED := 400.0

export var _navigation2d_path: NodePath
export var _player_path: NodePath

onready var _navigator: Navigation2D = get_node(_navigation2d_path)
onready var _player: Player = get_node(_player_path)

onready var _ship: KinematicBody2D = $PathFollow2D/Enemy
onready var _line: Line2D = $PathFollow2D/Enemy/Line2D
onready var _path_follow: PathFollow2D = $PathFollow2D
onready var _timer: Timer = $PathFollow2D/Enemy/Timer
onready var _tween: Tween = $PathFollow2D/Tween


func _ready() -> void:
	_timer.connect("timeout", self, "_on_Timer_timeout")
# END: onready

func _process(_delta: float) -> void:
	_line.look_at(_player.position)

# ANCHOR: timeout
func _on_Timer_timeout() -> void:
	curve.clear_points()
	for point in _navigator.get_simple_path(_path_follow.position, _player.position):
		curve.add_point(point)
	_tween.interpolate_property(
		_path_follow, "unit_offset", 0.0, 1.0, curve.get_baked_length() / SPEED
	)
	_tween.start()
# END: timeout
