extends Node2D

onready var _path_follow: PathFollow2D = $SmartEnemy/PathFollow2D
onready var _tween: Tween = $SmartEnemy/PathFollow2D/Tween
onready var waypoints: Array = $Waypoints.get_children()
onready var _navigation: Navigation2D = $Navigation2D
onready var _black_hole: Area2D = $BlackHole
onready var _path: Path2D = $SmartEnemy


func _ready() -> void:
	randomize()
	_tween.connect("tween_all_completed", self, "update_destination")
	_black_hole.connect("update_position", _navigation, "setup_hazards")
	_navigation.connect("navigation_updated", self, "follow_path")
	_path_follow.position = waypoints.front().position
	_navigation.setup_hazards()


func update_destination() -> void:
	waypoints.shuffle()
	follow_path()


func follow_path() -> void:
	_path.curve.clear_points()
	for point in _navigation.get_simple_path(
		_path_follow.position, waypoints.front().position
	):
		_path.curve.add_point(point)
	_tween.interpolate_property(
		_path_follow, "unit_offset", 0.0, 1.0, _path.curve.get_baked_length() / 666
	)
	_tween.start()
