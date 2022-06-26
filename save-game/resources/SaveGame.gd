class_name SaveGame
extends Resource

# You must use the user:// path prefix when saving the player's data. The .tres
# extension stands for "text resource."
const SAVE_GAME_PATH := "user://save.tres"

# Use this to detect old player saves and update their data.
export var version := 1

# We directly reference the characters stats and inventory in the save game resource.
# When saving this resource, they'll get saved alongside it. 
export var character: Resource
export var inventory: Resource

export var map_name := ""
export var global_position := Vector2.ZERO


# The next three functions are just to keep the save API inside of the SaveGame resource.
func write_savegame() -> void:
	ResourceSaver.save(SAVE_GAME_PATH, self)


static func save_exists() -> bool:
	return ResourceLoader.exists(SAVE_GAME_PATH)


static func load_savegame() -> Resource:
	if not ResourceLoader.has_cached(SAVE_GAME_PATH):
		# Once the resource caching bug is fixed, you will only need this line of code to load the save game.
		return ResourceLoader.load(SAVE_GAME_PATH, "", true)
	
	# /!\ Workaround for bug https://github.com/godotengine/godot/issues/59686
	# Without that, sub-resources will not reload from the saved data.
	# We copy the SaveGame resource's data to a temporary file, load that file
	# as a resource, and make it take over the save game.

	# We first load the save game resource's content as text and store it.
	var file := File.new()
	if file.open(SAVE_GAME_PATH, File.READ) != OK:
		printerr("Couldn't read file " + SAVE_GAME_PATH)
		return null

	var data := file.get_as_text()
	file.close()

	# Then, we generate a random file path that's not in Godot's cache.
	var tmp_file_path := make_random_path()
	while ResourceLoader.has_cached(tmp_file_path):
		tmp_file_path = make_random_path()

	# We write a copy of the save game to that temporary file path.
	if file.open(tmp_file_path, File.WRITE) != OK:
		printerr("Couldn't write file " + tmp_file_path)
		return null
	
	file.store_string(data)
	file.close()

	# We load the temporary file as a resource.
	var save = ResourceLoader.load(tmp_file_path, "", true)
	# And make it take over the SAVE_GAME_PATH for the next time the player
	# saves.
	save.take_over_path(SAVE_GAME_PATH)

	# We delete the temporary file.
	var directory := Directory.new()
	directory.remove(tmp_file_path)
	return save


static func make_random_path() -> String:
	return "user://temp_file_" + str(randi()) + ".tres"
