## This version of the demo uses JSON for saving and loading.
## Updated to work with typed arrays of ItemStack objects in Godot 4.
class_name SaveGameAsJSON
extends RefCounted

const SAVE_GAME_PATH := "user://save.json"

var version := 1

var character := Character.new()
var inventory := Inventory.new()

var global_position := Vector2.ZERO


func save_exists() -> bool:
	return FileAccess.file_exists(SAVE_GAME_PATH)


func write_savegame() -> void:
	var file := FileAccess.open(SAVE_GAME_PATH, FileAccess.WRITE)
	if not file:
		printerr("Could not open the file %s. Aborting save operation. Error code: %s" % [SAVE_GAME_PATH, FileAccess.get_open_error()])
		return

	# We need to convert the data to be compatible with JSON. This is what we do here.
	var inventory_data: Array = []
	for item_stack in inventory.items:
		inventory_data.append(
			{
				"unique_id": item_stack.unique_id,
				"amount": item_stack.amount,
			},
		)

	var data := {
		"version": version,
		"global_position": {
			"x": global_position.x,
			"y": global_position.y,
		},
		"player": {
			"display_name": character.display_name,
			"run_speed": character.run_speed,
			"level": character.level,
			"experience": character.experience,
			"strength": character.strength,
			"endurance": character.endurance,
			"intelligence": character.intelligence,
		},
		"inventory": inventory_data,
	}

	var json_string := JSON.stringify(data, "\t")
	file.store_string(json_string)
	file.close()


func load_savegame() -> void:
	var file := FileAccess.open(SAVE_GAME_PATH, FileAccess.READ)
	if not file:
		printerr("Could not open the file %s. Aborting load operation. Error code: %s" % [SAVE_GAME_PATH, FileAccess.get_open_error()])
		return

	var content := file.get_as_text()
	file.close()

	var json = JSON.new()
	var error := json.parse(content)
	if error != OK:
		printerr("Failed to parse JSON save file. Error: %s" % json.get_error_message())
		return

	var data: Dictionary = json.data
	global_position = Vector2(data.global_position.x, data.global_position.y)

	# After loading from JSON, we need to manually restore the typed Resource properties.
	character = Character.new()
	character.display_name = data.player.display_name
	character.run_speed = data.player.run_speed
	character.level = data.player.level
	character.experience = data.player.experience
	character.strength = data.player.strength
	character.endurance = data.player.endurance
	character.intelligence = data.player.intelligence

	inventory = Inventory.new()
	var inventory_data: Array = data.inventory
	for item_data in inventory_data:
		var item_stack := ItemStack.new(item_data.get("unique_id", ""), item_data.get("amount", 1))
		inventory.items.append(item_stack)
