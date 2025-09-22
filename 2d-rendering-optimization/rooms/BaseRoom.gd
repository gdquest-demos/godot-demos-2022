# This is the base script each room should use or extend.
#
# It handles hiding and showing bridges.
class_name BaseRoom
extends Node2D

const BRIDGES_DEFAULT_SIZE := Vector2(2, 2)

# The tiles indices in the "invisible wall" tileset
const INVALID_SOURCE := 2
const INVISIBLE_LEDGE_ATLAS_COORDINATE := Vector2i.ZERO
const INVISIBLE_WALL_ATLAS_COORDINATE := Vector2i.RIGHT

@export var use_visibility_notifier := false: set = set_use_visibility_notifier

# We use Rect2 values to represents the regions of the tile map where we drew
# bridges. This allows us to erase bridges that are outside of the game grid
# (the ones that don't lead to a room).
@export var top_bridge := Rect2(Vector2(5, -2), BRIDGES_DEFAULT_SIZE)
@export var right_bridge := Rect2(Vector2(11, 4), BRIDGES_DEFAULT_SIZE)
@export var left_bridge := Rect2(Vector2(-2, 4), BRIDGES_DEFAULT_SIZE)
@export var bottom_bridge := Rect2(Vector2(5, 11), BRIDGES_DEFAULT_SIZE)

var _notifier: VisibleOnScreenNotifier2D = null

@onready var _visibility_2d: Node2D = %Visibility2D
@onready var _bridges: TileMapLayer = %BridgesTileMapLayer
@onready var _limits: TileMapLayer = %LimitsTileMapLayer


func set_use_visibility_notifier(value: bool) -> void:
	use_visibility_notifier = value
	if not _limits:
		await ready

	if use_visibility_notifier:
		_notifier = VisibleOnScreenNotifier2D.new()
		_notifier.connect("screen_entered", _visibility_2d.show)
		_notifier.connect("screen_exited",  _visibility_2d.hide)
		_notifier.rect = Rect2(Vector2(-256.0, -256.0), Vector2(1920.0, 1920.0))
		add_child(_notifier)
		_visibility_2d.hide()
	else:
		if _notifier:
			_notifier.free()
		_visibility_2d.call_deferred("show")


func hide_top_bridge() -> void:
	_hide_bridge(top_bridge)


func hide_left_bridge() -> void:
	_hide_bridge(left_bridge)


func hide_right_bridge() -> void:
	_hide_bridge(right_bridge)


func hide_bottom_bridge() -> void:
	_hide_bridge(bottom_bridge)


# Hides a set of bridge cells within a 2D rectangle and replaces them with
# invisible walls to prevent the player from leaving the room and walking over
# the sky.
func _hide_bridge(bridge_region: Rect2) -> void:
	var start := bridge_region.position
	var end := start + bridge_region.size

	var x_range := range(start.x, end.x)
	var y_range := range(start.y, end.y)

	# We loop over all cells between
	for x in x_range:
		for y in y_range:
			var cell_coordinates := Vector2(x, y)
			# We remove the tile from the bridge tilemap. Passing -1 to the
			# set_cellv() function erases the tile at cell_coordinates.
			_bridges.set_cell(cell_coordinates)
			# In the limits tilemap, we draw an invisible wall to block the
			# player.
			_limits.set_cell(cell_coordinates, INVALID_SOURCE, INVISIBLE_WALL_ATLAS_COORDINATE)

	# There's a ledge at the bottom of islands, we need to add extra half-size
	# invisible walls in this case.
	if bridge_region == bottom_bridge:
		for x in range(start.x, end.x):
			var ledge_cell_coordinates := Vector2(x, bottom_bridge.position.y - 1)
			_limits.set_cell(ledge_cell_coordinates, INVALID_SOURCE, INVISIBLE_LEDGE_ATLAS_COORDINATE)
