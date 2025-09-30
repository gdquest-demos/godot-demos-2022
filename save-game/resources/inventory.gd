class_name Inventory
extends Resource

# Godot 4 supports typed arrays! We can now store an array of ItemStack objects
# directly in the inventory resource.
#
# Note: We use Array[Resource] instead of Array[ItemStack] because Godot 4's
# typed arrays with custom classes can sometimes have issues with serialization.
# The ItemStack class is defined in item_stack.gd.
@export var items: Array[ItemStack] = []


func add_item(unique_id: String, amount := 1) -> void:
	# Try to find an existing stack with this item
	# If we don't find it, create a new stack
	for item_stack in items:
		if item_stack.unique_id == unique_id:
			item_stack.amount += amount
			emit_changed()
			return

	var new_stack := ItemStack.new(unique_id, amount)
	items.append(new_stack)
	emit_changed()


func get_amount(item_unique_id: String) -> int:
	for item_stack in items:
		if item_stack.unique_id == item_unique_id:
			return item_stack.amount

	printerr("Trying to get the amount of item %s but the inventory doesn't have it." % item_unique_id)
	return 0


func remove_item(item_unique_id: String, amount := 1) -> void:
	for i in range(items.size()):
		var item_stack := items[i]
		if item_stack.unique_id == item_unique_id:
			item_stack.amount -= amount
			if item_stack.amount <= 0:
				items.remove_at(i)
			emit_changed()
			return

	printerr("Trying to remove item %s but the inventory doesn't have it." % item_unique_id)


# Helper function to check if an item exists in the inventory
func has_item(item_unique_id: String) -> bool:
	for item_stack in items:
		if item_stack.unique_id == item_unique_id:
			return true
	return false
