extends Spatial

export var open := false

onready var _tween := $Tween
onready var _door := $DoorGreen/door_base_green/door_green
onready var _positions := [
	_door.translation,
	_door.translation - Vector3(0.0, 1.97, 0.0)
]


func _ready() -> void:
	if open:
		activate()


func activate() -> void:
	_positions.push_back(_positions.pop_front())
	_tween.stop_all()
	_tween.interpolate_property(
		_door,
		"translation",
		_door.translation,
		_positions.front(),
		1.5,
		Tween.TRANS_ELASTIC,
		Tween.EASE_IN_OUT
	)
	_tween.start()
