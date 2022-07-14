# This example shows how to use JSON to save and load game data, ensuring that 
# there can be no arbitrary code execution. In Godot 3, for that, you can use JSON, 
# XML, your own text format, or binary data.
#
# Other options like ConfigFile or str2var or tscn and text resources can 
# execute code.
class_name SaveGameAsJSON
# This time we extend from reference as we won´t be using the resource saving
# and loading system.
extends Reference

const SAVE_GAME_PATH := "user://save.json"

# Use this to detect old player saves and update their data.
export var version := 1

# We reference resources in our save game so that when the state updates in some
# other game system the data is also available from here.
export var character: Resource = Character.new()
export var inventory: Resource = Inventory.new()

export var map_name := ""
export var global_position := Vector2.ZERO

var _file := File.new()


func save_exists() -> bool:
	return _file.file_exists(SAVE_GAME_PATH)


# This function shows how to save the game data using JSON instead of
# the built-in resource saver.
#
# You can use this to:
#
# 1. Ensure that your save game can't run arbitrary code. See the security
# section of this demo's README.
# 2. Disconnect the saved data from resource scripts.
func write_savegame() -> void:
	var error := _file.open(SAVE_GAME_PATH, File.WRITE)
	if error != OK:
		printerr("Could not open the file %s. Aborting save operation. Error code: %s" % [SAVE_GAME_PATH, error])
		return

	# With JSON, you start by making a dictionary, then convert it.
	var data := {
		# JSON doesn't support converting built-in types like vectors or
		# transforms, so you need to separate individual numbers.
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
		# We already store items as a mapping of String to int, so we can
		# reference it in the JSON data.
		"inventory": inventory.items,
	}
	
	var json_string := JSON.print(data)
	_file.store_string(json_string)
	_file.close()


# When loading, we convert the JSON data back into resources to be able to share
# them with other game objects.
func load_savegame() -> void:
	var error := _file.open(SAVE_GAME_PATH, File.READ)
	if error != OK:
		printerr("Could not open the file %s. Aborting load operation. Error code: %s" % [SAVE_GAME_PATH, error])
		return

	var content := _file.get_as_text()
	_file.close()

	var data: Dictionary = JSON.parse(content).result
	# JSON doesn't support built-in Godot types, so you need to rebuild vectors
	# etc. when loading.
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
