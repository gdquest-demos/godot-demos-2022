extends Node2D

@export var rooms: Array[PackedScene] = []
@export var grid_width := 20
@export var grid_height := 20
@export var room_size := Vector2(13, 13) * 128

var _rooms: Array[BaseRoom] = []

@onready var _checkbox: CheckBox = %NotifiersCheckBox


func _ready() -> void:
	randomize()
	_generate_level()
	_checkbox.toggled.connect(_toggle_optimization)


func _generate_level() -> void:
	for x in grid_width:
		for y in grid_height:
			var RoomScene: PackedScene = rooms[randi() % rooms.size()]
			var room: BaseRoom = RoomScene.instantiate()
			_rooms.append(room)

			var room_grid_position := Vector2(x, y)
			room.global_position = room_size * room_grid_position
			add_child(room)

			# We remove bridges when there are no connected rooms.
			if x == 0:
				room.remove_left_bridge()
			elif x == grid_width - 1:
				room.remove_right_bridge()

			if y == 0:
				room.remove_top_bridge()
			elif y == grid_height - 1:
				room.remove_bottom_bridge()


func _toggle_optimization(is_toggled: bool) -> void:
	for room in _rooms:
		room.use_visibility_notifier = is_toggled
