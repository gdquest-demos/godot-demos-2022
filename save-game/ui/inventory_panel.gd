extends Control

const ItemPanelScene := preload("item_panel.tscn")

# This menu displays the content of this inventory resource. Clicking the
# buttons to add or remove items directly removes them from this resource.
var inventory: Inventory = null:
	set = set_inventory

@onready var _item_grid_container: GridContainer = %ItemGridContainer
@onready var _tooltip_panel: Panel = %TooltipPanel
@onready var _add_item_button: Button = %AddItemButton
@onready var _remove_item_button: Button = %RemoveItemButton


func _ready() -> void:
	_add_item_button.pressed.connect(_add_random_item)
	_remove_item_button.pressed.connect(_remove_random_item)

	# If running the scene with F6, we create an inventory for testing purposes.
	if get_parent() == get_tree().root:
		var test_inventory := Inventory.new()
		test_inventory.add_item("healing_gem", 3)
		test_inventory.add_item("sword", 2)
		set_inventory(test_inventory)


func set_inventory(new_inventory: Inventory) -> void:
	if inventory != new_inventory:
		new_inventory.changed.connect(_update_items_display)

	inventory = new_inventory
	_update_items_display()


func _update_items_display() -> void:
	for node in _item_grid_container.get_children():
		node.queue_free()

	for item_unique_id in inventory.items:
		var item_panel: ItemPanel = ItemPanelScene.instantiate()
		_item_grid_container.add_child(item_panel)
		item_panel.display_item(item_unique_id, inventory.get_amount(item_unique_id))
		item_panel.tooltip_requested.connect(_on_tooltip_requested.bind(item_panel))


func _on_tooltip_requested(item_panel: ItemPanel) -> void:
	var description := ItemDatabase.get_item_data(item_panel.item_unique_id).description
	_tooltip_panel.display(description, get_global_mouse_position())


func _add_random_item() -> void:
	var item_unique_id: String = ItemDatabase.ITEMS.keys()[randi() % ItemDatabase.ITEMS.keys().size()]
	inventory.add_item(item_unique_id)


func _remove_random_item() -> void:
	if inventory.items:
		inventory.remove_item(inventory.items.keys()[randi() % inventory.items.keys().size()])
