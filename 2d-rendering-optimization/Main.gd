extends YSort

export(Array, PackedScene) var rooms := []
export var grid_width := 20
export var grid_height := 20
export var room_size := Vector2(13, 13) * 128

var _rooms := []

onready var _checkbox := $UILayer/VBoxContainer/CheckBox


func _ready() -> void:
	randomize()
	generate_level()
	_checkbox.connect("toggled", self, "_toggle_optimization")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen


func generate_level() -> void:
	var last_room_index := (grid_width * grid_height)  - 1
	for x in grid_width:
		for y in grid_height:
			var RoomScene: PackedScene = rooms[randi() % rooms.size()]
			var room: BaseRoom = RoomScene.instance()
			_rooms.append(room)
			
			var room_position := Vector2(x, y)
			room.global_position = room_size * room_position
			add_child(room)
			
			# We hide bridges when there are no connected rooms.
			if x == 0:
				room.hide_left_bridge()
			elif x == grid_width - 1:
				room.hide_right_bridge()
			if y == 0:
				room.hide_top_bridge()
			elif y == grid_height - 1:
				room.hide_bottom_bridge()


func _toggle_optimization(is_on: bool) -> void:
	for room in _rooms:
		room.set_use_visibility_notifier(is_on)
