extends Control

onready var box_list := [
	get_node("%Box1"),
	get_node("%Box2"),
	get_node("%Box3")
]


func _ready() -> void:
	for box in box_list:
		box.rect_scale = Vector2.ZERO
		pass

# ANCHOR: animate
func animate_rectangles_appearing() -> void:
	var _tween := create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	for box in box_list:
		box.rect_scale = Vector2.ZERO
		box = box as TextureRect
		box.rect_rotation = -30.0
		# We animate the rectangle's scale and rotation over one second, using the elastic easing equation.
		_tween.tween_property(box, "rect_scale", Vector2.ONE, 0.5)
		# CAREFUL, this needs to be 0.0 and not just `0`, or else the tween
		# will complain about floats vs ints
		_tween.parallel().tween_property(box, "rect_rotation", 0.0, 1.0)
# END: animate


func _on_PopButton_pressed() -> void:
	animate_rectangles_appearing()
