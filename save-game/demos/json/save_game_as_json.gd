## This version of the demo uses JSON just for saving and loading.
## 
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

	var data := {
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
		"inventory": inventory.items,
	}

	var json_string := JSON.stringify(data)
	file.store_string(json_string)
	file.close()


func load_savegame() -> void:
	var file := FileAccess.open(SAVE_GAME_PATH, FileAccess.READ)
	if not file:
		printerr("Could not open the file %s. Aborting load operation. Error code: %s" % [SAVE_GAME_PATH, FileAccess.get_open_error()])
		return

	var content := file.get_as_text()
	file.close()

	var test_json_conv = JSON.new()
	test_json_conv.parse(content)
	var data: Dictionary = test_json_conv.data
	global_position = Vector2(data.global_position.x, data.global_position.y)

	character = Character.new()
	character.display_name = data.player.display_name
	character.run_speed = data.player.run_speed
	character.level = data.player.level
	character.experience = data.player.experience
	character.strength = data.player.strength
	character.endurance = data.player.endurance
	character.intelligence = data.player.intelligence

	inventory = Inventory.new()
	inventory.items = data.inventory
