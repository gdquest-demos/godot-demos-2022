extends Panel

@onready var label: Label = %Label

var _hide_rect := Rect2()


func _ready() -> void:
	top_level = true
	set_process(false)


func _process(_delta: float) -> void:
	if not _hide_rect.has_point(get_global_mouse_position()):
		_hide()


func _hide() -> void:
	set_process(false)
	hide()


func _show() -> void:
	_hide_rect = get_global_rect().grow(40.0)
	set_process(true)
	show()


func display(text: String, global_position: Vector2) -> void:
	position = global_position
	label.text = text
	_show()
