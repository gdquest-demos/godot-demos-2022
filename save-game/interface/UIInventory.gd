extends Control

const UIItemScene := preload("UIItem.tscn")

var inventory: Inventory = null setget set_inventory

onready var _item_grid := $VBoxContainer/ItemGrid as GridContainer
onready var _ui_tooltip := $UITooltip

onready var _add_item_button := $VBoxContainer/HBoxContainer/AddItemButton as Button
onready var _remove_item_button := $VBoxContainer/HBoxContainer/RemoveItemButton as Button

func _ready() -> void:
	_add_item_button.connect("pressed", self, "_add_random_item")
	_remove_item_button.connect("pressed", self, "_remove_random_item")


func set_inventory(new_inventory: Inventory) -> void:
	if inventory != new_inventory:
		new_inventory.connect("changed", self, "_update_items_display")
	inventory = new_inventory
	_update_items_display()


func _update_items_display() -> void:
	for node in _item_grid.get_children():
		node.queue_free()
	
	for item_unique_id in inventory.items:
		var ui_item: UIItem = UIItemScene.instance()
		_item_grid.add_child(ui_item)
		ui_item.display_item(item_unique_id, inventory.get_amount(item_unique_id))
		ui_item.connect("tooltip_requested", self, "_on_tooltip_requested", [ui_item])


func _on_tooltip_requested(ui_item: UIItem) -> void:
	var description := ItemDatabase.get_item_data(ui_item.item_unique_id).description
	_ui_tooltip.display(description, get_global_mouse_position())


func _add_random_item() -> void:
	var item_unique_id: String = ItemDatabase.ITEMS.keys()[randi() % ItemDatabase.ITEMS.keys().size()]
	inventory.add_item(item_unique_id)


func _remove_random_item() -> void:
	if inventory.items:
		inventory.remove_item(inventory.items.keys()[randi() % inventory.items.keys().size()])
