extends Spatial

# ANCHOR: setup
## Maximum rotation we apply to cards on the edges of the hand.
const CARD_ROTATION := deg2rad(15.0)
## Horizontal spread of the hands on the Z axis.
const HAND_SPREAD := 5.0
## Offset applied to each card towards the camera to render them in the correct
## order.
const HEIGHT_DIFFERENCE := 0.02

export(PackedScene) var card_scene

export var minimum_hand_size := 2
export var maximum_hand_size := 6
# We place cards along this curve.
export var height_curve: Curve
# This curve controls the amount of rotation applied to each card.
export var rotation_curve: Curve

onready var hand: Spatial = $Player/Hand
onready var deck: Area = $Player/Deck
onready var cards_resting_place: Area = $Player/CardsRestingPlace


func _ready() -> void:
	deck.connect("clicked", self, "_on_cards_requested")
	cards_resting_place.connect("area_entered", self, "_on_CardsRestingPlace_area_entered")


func _calculate_new_card_transform(index: int, count: int, ratio_in_hand: float) -> Transform:
	var new_translation := Vector3(
		# Due to our camera's rotation, the X axis moves the card forward.
		height_curve.interpolate(ratio_in_hand) * 2.0,
		# This line offsets each card up so it appears in front of the one
		# before it.
		index * HEIGHT_DIFFERENCE,
		# We spread cards horizontally on the screen using the Z axis.
		-(HAND_SPREAD * count * 0.5) + index * HAND_SPREAD
	)
	var new_angle := -PI / 2.0 + rotation_curve.interpolate(ratio_in_hand) * CARD_ROTATION
	# The basis is a group of three vectors representing the object's local
	# axes, giving us information about its orientation and scale.
	var new_rotation_and_scale := Basis(Vector3.UP, new_angle).scaled(Vector3.ONE * 2.0)
	# We can build a tranform from a basis and a translation to pack position,
	# rotation, and scale in a single value. That's handy for animation!
	return Transform(new_rotation_and_scale, new_translation)


func _clear() -> void:
	if hand.get_children().empty():
		return

	var tween := create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	for child in hand.get_children():
		tween.tween_property(child, "translation", cards_resting_place.translation, 1)


func _on_cards_requested() -> void:
	_clear()

	var tween := create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

	var adjusted_card_count := int(rand_range(1, 5))

	for child_index in adjusted_card_count + 1:
		var new_card: Card3D = card_scene.instance()
		new_card.card_art = preload("res://assets/blackhole.png")
		new_card.card_name = "Black Hole"
		new_card.translation = deck.translation
		new_card.scale = Vector3.ZERO
		new_card.translation.z -= 1

		hand.add_child(new_card)

		var ratio_in_hand := float(child_index) / adjusted_card_count
		var new_transform: Transform = _calculate_new_card_transform(
			child_index, adjusted_card_count, ratio_in_hand
		)

		tween.tween_property(new_card, "scale", Vector3.ONE * 0.8, .2)
		tween.parallel().tween_property(new_card, "translation:x", new_card.translation.x + 3, .3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(new_card, "transform", new_transform, 0.5)


func _on_CardsRestingPlace_area_entered(card: Node) -> void:
	card.queue_free()
