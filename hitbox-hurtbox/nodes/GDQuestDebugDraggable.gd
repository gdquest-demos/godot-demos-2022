# When added as a child of a CollisionObject2D, makes that object movable with
# click and drag. Uses the parent's first collision shape as the drag and drop area.
class_name GDQuestDebugDraggable, "GDQuestDebugDraggable.svg"
extends Area2D

var _click_offset := Vector2.ZERO
var _collision_shape := CollisionShape2D.new()

onready var _parent := get_parent() as CollisionObject2D
onready var tree := get_tree()


func _ready() -> void:
	if not _parent:
		input_pickable = false
		return

	var shape := _parent.shape_owner_get_shape(0, 0)
	if not shape:
		input_pickable = false
		return

	_collision_shape.shape = shape
	_collision_shape.transform = _parent.shape_owner_get_transform(0)
	add_child(_collision_shape)
	set_physics_process(false)



func _input_event(_viewport: Object, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		set_physics_process(true)
		_click_offset = get_local_mouse_position().rotated(global_rotation)


func _input(event: InputEvent) -> void:
	if event.is_action_released("click"):
		set_physics_process(false)
		# As areas don't update as fast as other nodes, when dragging really fast they can get 
		# offset from the parent on mouse release.
		set_deferred("global_position", _parent.global_position)

func _physics_process(_delta: float) -> void:
	global_position = get_global_mouse_position() - _click_offset
	_parent.global_position = global_position
