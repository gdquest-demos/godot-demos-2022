extends Spatial

# ANCHOR: setup
## Maximum rotation we apply to cards on the edges of the hand.
const CARD_ROTATION := deg2rad(15.0)
## Horizontal spread of the hands on the Z axis.
const HAND_SPREAD := 5.0
## Offset applied to each card towards the camera to render them in the correct
## order.
const HEIGHT_DIFFERENCE := 0.02

export var minimum_hand_size := 2
export var maximum_hand_size := 6
# We place cards along this curve.
export var height_curve: Curve
# This curve controls the amount of rotation applied to each card.
export var rotation_curve: Curve

onready var _cards: Spatial = $Cards
onready var _tween: Tween = $Tween
# END: setup


func _ready() -> void:
	_align_cards()


func add_card(card: Card3D) -> void:
	if _cards.get_child_count() >= maximum_hand_size:
		return

	card.connect("input_event", self, "_on_Card_input_event")

	_cards.add_child(card)
	card.scale = Vector3.ZERO

	card.visible = true
	_align_cards()


# ANCHOR: align
func _align_cards() -> void:
	var adjusted_card_count := _cards.get_child_count() - 1
	for child_index in _cards.get_child_count():
		# We use this line to get type checks and autocompletion in the editor.
		var card := _cards.get_child(child_index) as Card3D

		var ratio_in_hand := float(child_index) / adjusted_card_count
		var new_transform := _calculate_new_card_transform(child_index, adjusted_card_count, ratio_in_hand)

		# ANCHOR: tween
		_tween.interpolate_property(
			card, "transform", card.transform, new_transform, 1.2, Tween.TRANS_EXPO, Tween.EASE_OUT
		)
		# END: tween
	_tween.start()
# END: align


# ANCHOR: calculate_transform
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
# END: calculate_transform


func _on_Card_input_event(_camera, event: InputEvent, _click_position, _click_normal, _shape_idx) -> void:
	if not event.is_action_released("click"):
		return

	if not _cards.get_child_count() > minimum_hand_size:
		return

	var card = _cards.get_children().pop_back()

	_cards.remove_child(card)
	card.queue_free()

	_align_cards()
