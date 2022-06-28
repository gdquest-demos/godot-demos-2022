extends Navigation2D
# ANCHOR: modes
export var west_door_path: NodePath
export var north_door_path: NodePath

onready var _west_door: StaticBody2D = get_node(west_door_path)
onready var _north_door: StaticBody2D = get_node(north_door_path)
onready var door_map := {
	_west_door: $WestRoomUnlockedPolygon, _north_door: $NorthRoomUnlockedPolygon
}


func _ready() -> void:
	_west_door.activate()
	door_map[_west_door].enabled = true


func activate() -> void:
	for door in door_map:
		door.activate()
		door_map[door].enabled = door.activated
# END: modes
