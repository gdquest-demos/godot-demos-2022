extends Control

onready var box_list := get_tree().get_nodes_in_group("box")
onready var button := $Button


func _ready() -> void:
	button.connect("pressed", self, "animate_rectangles_appearing")
	for box in box_list:
		box.rect_scale = Vector2.ZERO


func animate_rectangles_appearing() -> void:
	for box in box_list:
		box.rect_scale = Vector2.ZERO

	var tween := create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	for box in box_list:
		box.rect_rotation = -30.0
		tween.tween_property(box, "rect_scale", Vector2.ONE, 0.5)
		tween.parallel().tween_property(box, "rect_rotation", 0.0, 1.0)
