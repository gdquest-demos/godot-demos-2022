# This is the base script for a dungeon room.
#
# It handles removing bridges, useful when rooms aren't connected to each other.
class_name BaseRoom extends Node2D

const BRIDGES_DEFAULT_SIZE := Vector2i(2, 2)

# The tiles indices in the "invisible wall" tileset
const INVALID_SOURCE := 1
const INVALID_LEDGE_ATLAS_COORDINATE := Vector2i.ZERO
const INVALID_WALL_ATLAS_COORDINATE := Vector2i.RIGHT
const HALF_BRIDGE_ATLAS_COORDINATE := Vector2i(12, 10)

@export var use_visibility_notifier := false:
	set(value):
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


# We use Rect2i values to represents the regions of the tile map where we drew
# bridges. This allows us to remove bridges that are outside of the game grid
# (the ones that don't lead to a room).
@export var top_bridge := Rect2i(Vector2i(5, -2), BRIDGES_DEFAULT_SIZE)
@export var right_bridge := Rect2i(Vector2i(11, 4), BRIDGES_DEFAULT_SIZE)
@export var left_bridge := Rect2i(Vector2i(-2, 4), BRIDGES_DEFAULT_SIZE)
@export var bottom_bridge := Rect2i(Vector2i(5, 10), BRIDGES_DEFAULT_SIZE + Vector2i.ONE)

var _notifier: VisibleOnScreenNotifier2D = null

@onready var _visibility_2d: Node2D = %Visibility2D
@onready var _bridges: TileMapLayer = %BridgesTileMapLayer
@onready var _limits: TileMapLayer = %LimitsTileMapLayer


func remove_top_bridge() -> void:
	_remove_bridge(top_bridge)


func remove_left_bridge() -> void:
	_remove_bridge(left_bridge)


func remove_right_bridge() -> void:
	_remove_bridge(right_bridge)


func remove_bottom_bridge() -> void:
	_remove_bridge(bottom_bridge)


# Removes a set of bridge cells within a 2D rectangle and replaces them with invisible walls
# to prevent the player from leaving the room and walking over the sky.
func _remove_bridge(bridge_region: Rect2i) -> void:
	var start := bridge_region.position
	var end := start + bridge_region.size

	# We loop over all cells between
	for x in range(start.x, end.x):
		for y in range(start.y, end.y):
			var cell_coordinates := Vector2i(x, y)

			# The bottom bridges use half-filled tiles on the top part. We want to replace those
			# with `INVALID_LEDGE_ATLAS_COORDINATE`, instead of the full invalid tile.
			var invalid_atlas_coordinate := (
				INVALID_LEDGE_ATLAS_COORDINATE
				if _bridges.get_cell_atlas_coords(cell_coordinates) == HALF_BRIDGE_ATLAS_COORDINATE
				else INVALID_WALL_ATLAS_COORDINATE
			)

			# In the limits tilemap, we draw an invisible wall to block the player.
			_limits.set_cell(cell_coordinates, INVALID_SOURCE, invalid_atlas_coordinate)

			# We remove the tile from the bridge tilemap. Passing only the coordinates to
			# the `set_cell()` function erases the tile at `cell_coordinates`.
			_bridges.set_cell(cell_coordinates)
