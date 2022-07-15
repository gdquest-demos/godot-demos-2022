class_name SaveGameAsJSON
extends Reference

const SAVE_GAME_PATH := "user://save.json"

var version := 1

var character: Resource = Character.new()
var inventory: Resource = Inventory.new()

var map_name := ""
var global_position := Vector2.ZERO

var _file := File.new()


func save_exists() -> bool:
	return _file.file_exists(SAVE_GAME_PATH)


func write_savegame() -> void:
	var error := _file.open(SAVE_GAME_PATH, File.WRITE)
	if error != OK:
		printerr("Could not open the file %s. Aborting save operation. Error code: %s" % [SAVE_GAME_PATH, error])
		return

	var data := {
		"global_position":
		{
			"x": global_position.x,
			"y": global_position.y,
		},
		"map_name": map_name,
		"player":
		{
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
	
	var json_string := JSON.print(data)
	_file.store_string(json_string)
	_file.close()


func load_savegame() -> void:
	var error := _file.open(SAVE_GAME_PATH, File.READ)
	if error != OK:
		printerr("Could not open the file %s. Aborting load operation. Error code: %s" % [SAVE_GAME_PATH, error])
		return

	var content := _file.get_as_text()
	_file.close()

	var data: Dictionary = JSON.parse(content).result
	global_position = Vector2(data.global_position.x, data.global_position.y)
	map_name = data.map_name

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
