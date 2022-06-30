extends Navigation
# ANCHOR: modes
export var north_door_path: NodePath
export var east_door_path: NodePath

onready var _north_door = get_node(north_door_path)
onready var _east_door = get_node(east_door_path)
onready var _door_map := {
	_north_door: $NorthDoorOpen,
	_east_door: $EastDoorOpen,
}


func _ready() -> void:
	for door in _door_map:
		door.activate()
		_door_map[door].enabled = !_door_map[door].enabled
# END: modes
