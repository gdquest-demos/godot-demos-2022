extends Area

signal card_drawn(card)

export(PackedScene) var card_scene


func _ready() -> void:
	connect("input_event", self, "_on_input_event")


func _on_input_event(_camera, event: InputEvent, _click_position, _click_normal, _shape_idx) -> void:
	if not event.is_action_released("ui_accept"):
		return

	var new_card: Card3D = card_scene.instance()
	new_card.card_art = preload("res://common/blackhole.png")
	new_card.card_name = "Black Hole"
	new_card.translation = translation

	emit_signal("card_drawn", new_card)
