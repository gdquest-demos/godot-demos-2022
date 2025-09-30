# Represents a stack of items in the inventory with a unique ID and quantity.
# This is a separate class (not an inner class) so it can be properly serialized
# when saving/loading resources in Godot 4.
class_name ItemStack
extends Resource

@export var unique_id := ""
@export var amount := 1


func _init(id := "", quantity := 1) -> void:
	unique_id = id
	amount = quantity
