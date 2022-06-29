extends Control

export(Array, Texture) var items := []

var current_item := 0

onready var add_item_button := $"%AddItemButton"
onready var remove_item_button := $"%RemoveItemButton"
onready var h_flow_container := $"%HFlowContainer"
onready var vslider := $"%VSlider"


func _ready() -> void:
	add_item_button.connect("pressed", self, "add_item")
	remove_item_button.connect("pressed", self, "remove_item")
	
	vslider.value = theme.get_constant("hseparation", "HFlowContainer")
	vslider.connect("value_changed", self, "set_margins")
	
	for _i in 6:
		add_item()


func add_item() -> void:
	var item = preload("Item.tscn").instance()
	item.set_deferred("texture", items[current_item])
	current_item = (current_item + 1) % items.size()
	h_flow_container.add_child(item)
	
	# Ensures the animation plays as the container resets the scale otherwise
	yield(get_tree(), "idle_frame")
	var tween :=  create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	item.rect_scale = Vector2.ZERO
	tween.tween_property(item, "rect_scale", Vector2.ONE, 0.3)


func remove_item() -> void:
	var last: Node = h_flow_container.get_child(h_flow_container.get_child_count() - 1)
	if last:
		h_flow_container.remove_child(last)


func set_margins(new_value: int) -> void:
	h_flow_container.add_constant_override("vseparation", new_value)
	h_flow_container.add_constant_override("hseparation", new_value)
