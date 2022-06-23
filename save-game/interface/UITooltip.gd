extends Panel

onready var label := $Label

var _hide_rect: Rect2


func _ready() -> void:
	set_as_toplevel(true)
	set_process(false)
	
	
func _process(_delta: float) -> void:
	if not _hide_rect.has_point(get_global_mouse_position()):
		hide()


func hide() -> void:
	.hide()
	set_process(false)


func show() -> void:
	.show()
	_hide_rect = get_global_rect().grow(40.0)
	set_process(true)


func display(text: String, global_position: Vector2) -> void:
	label.text = text
	rect_position = global_position
	show()
