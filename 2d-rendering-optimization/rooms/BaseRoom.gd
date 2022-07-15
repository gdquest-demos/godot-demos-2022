# This is the base script each room should use or extend.
#
# It handles hiding and showing bridges.
class_name BaseRoom
extends Node2D

const BRIDGES_DEFAULT_SIZE := Vector2(2, 2)

# The tiles indices in the "invisible wall" tileset
const INVISIBLE_WALL_TILE_INDEX := 1
const INVISIBLE_LEDGE_TILE_INDEX := 0

export var use_visibility_notifier := false setget set_use_visibility_notifier

# We use Rect2 values to represents the regions of the tile map where we drew
# bridges. This allows us to erase bridges that are outside of the game grid
# (the ones that don't lead to a room).
export var top_bridge := Rect2(Vector2(5, -2), BRIDGES_DEFAULT_SIZE)
export var right_bridge := Rect2(Vector2(11, 4), BRIDGES_DEFAULT_SIZE)
export var left_bridge := Rect2(Vector2(-2, 4), BRIDGES_DEFAULT_SIZE)
export var bottom_bridge := Rect2(Vector2(5, 11), BRIDGES_DEFAULT_SIZE)


var _notifier: VisibilityNotifier2D = null

onready var _bridges := $bridges
onready var _limits := $Limits


func _ready() -> void:
	_limits.hide()


func set_use_visibility_notifier(value: bool) -> void:
	use_visibility_notifier = value
	if not _limits:
		yield(self, "ready")

	if use_visibility_notifier:
		_notifier = VisibilityNotifier2D.new()
		_notifier.connect("screen_entered", self, "show")
		_notifier.connect("screen_exited", self, "hide")
		_notifier.rect = Rect2(Vector2(-300, -300), Vector2(2000, 2000))
		add_child(_notifier)
		visible = false
	else:
		if _notifier:
			_notifier.free()
		call_deferred("show")


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
			_bridges.set_cellv(cell_coordinates, -1)
			# In the limits tilemap, we draw an invisible wall to block the
			# player.
			_limits.set_cellv(cell_coordinates, INVISIBLE_WALL_TILE_INDEX)

	# There's a ledge at the bottom of islands, we need to add extra half-size
	# invisible walls in this case.
	if bridge_region == bottom_bridge:
		for x in range(start.x, end.x):
			var ledge_cell_coordinates := Vector2(x, bottom_bridge.position.y - 1)
			_limits.set_cellv(ledge_cell_coordinates, INVISIBLE_LEDGE_TILE_INDEX)

