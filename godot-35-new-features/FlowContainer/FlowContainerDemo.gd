extends Control

export(Array, Texture) var items := []

onready var window_dialog: WindowDialog = $WindowDialog
onready var add_item_button: Button = $WindowDialog/MarginContainer/HBoxContainer/VFlowContainer/AddItemButton
onready var remove_item_button: Button = $WindowDialog/MarginContainer/HBoxContainer/VFlowContainer/RemoveItemButton
onready var margins_increase_button: Button = $WindowDialog/MarginContainer/HBoxContainer/VFlowContainer/MarginsIncreaseButton
onready var margins_decrease_button: Button = $WindowDialog/MarginContainer/HBoxContainer/VFlowContainer/MarginsDecreaseButton
onready var h_flow_container: HFlowContainer = $WindowDialog/MarginContainer/HBoxContainer/ScrollContainer/HFlowContainer
onready var open_inventory_button: Button = $OpenInventoryButton

var margins := 0
var current_item := 0


func _ready() -> void:
	open_inventory_button.connect("pressed", window_dialog, "popup_centered")
	window_dialog.connect("about_to_show", open_inventory_button, "hide")
	window_dialog.connect("popup_hide", open_inventory_button, "show")
	window_dialog.popup_centered()
	
	add_item_button.connect("pressed", self, "add_item")
	remove_item_button.connect("pressed", self, "remove_item")
	
	margins_increase_button.connect("pressed", self, "set_margins", [1])
	margins_decrease_button.connect("pressed", self, "set_margins", [-1])
	
	var tween := create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	for _i in 3:
		add_item(tween, .2)


func add_item(
		tween := create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT), 
		popup_time := .4
	) -> void:
	var size := Vector2(128, 128)
	var panel := PanelContainer.new()
	panel.rect_size = size
	panel.rect_min_size = size
	panel.rect_pivot_offset = size/2
	
	var texture := TextureRect.new()
	texture.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texture.size_flags_vertical = Control.SIZE_EXPAND_FILL
	texture.texture = items[current_item]
	current_item = (current_item + 1) % items.size()
	texture.expand = true
	texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	panel.add_child(texture)
	h_flow_container.add_child(panel)

	# TODO: Scroll is not following focus?
	panel.focus_mode = Control.FOCUS_ALL
	panel.grab_focus()
	
	if tween == null:
		return
	
	# Necessary because scale gets reset by parent container
	yield(get_tree(), "idle_frame")
	panel.rect_scale = Vector2.ZERO
	tween.tween_property(panel, "rect_scale", Vector2.ONE, popup_time)


func remove_item() -> void:
	var last: Node = h_flow_container.get_child(h_flow_container.get_child_count() - 1)
	if last:
		h_flow_container.remove_child(last)


func set_margins(inc: int) -> void:
	margins += inc
	h_flow_container.add_constant_override("vseparation", margins)
	h_flow_container.add_constant_override("hseparation", margins)
	
