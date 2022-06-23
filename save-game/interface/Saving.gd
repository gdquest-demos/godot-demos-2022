extends Control

const ITEMS := [
	preload("res://resources/items/Boomerang.tres"),
	preload("res://resources/items/Sword.tres"),
	preload("res://resources/items/Wand.tres"),
	preload("res://resources/items/HealingGem.tres"),
	preload("res://resources/items/FireGem.tres"),
]

onready var ui_inventory := $UIInventory
onready var save_button := $Panel/HBoxContainer/SaveButton
onready var add_button := $Panel/HBoxContainer/AddItemButton
onready var remove_item_button := $Panel/HBoxContainer/RemoveItemButton


func _ready() -> void:
	save_button.connect("pressed", ui_inventory.inventory, "save")
	add_button.connect("pressed", self, "_on_AddItemButton_pressed")
	remove_item_button.connect("pressed", self, "_on_RemoveItemButton_pressed")
#
#
#func _on_AddItemButton_pressed() -> void:
#	var item_model: Item = ITEMS[randi() % ITEMS.size()]
#	var item := item_model.duplicate()
#	ui_inventory.inventory.add_item(item)


#func _on_RemoveItemButton_pressed() -> void:
#	ui_inventory.inventory.pop_last_item()
