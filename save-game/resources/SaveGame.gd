# Save and load the game using the text or binary resource format.
#
# /!\ This approach is unsafe if players download completed save games from the 
# web. Please read the README and watch the corresponding video about security
# issues.
class_name SaveGame
extends Resource

# You must use the user:// path prefix when saving the player's data.
#
# We removed the extension in this demo to show how to save as text during
# development or in debug builds and binary in the released game.
#
# See the get_save_path() function below.
const SAVE_GAME_BASE_PATH := "user://save"

# Use this to detect old player saves and update their data.
export var version := 1

# We directly reference the characters stats and inventory in the save game resource.
# When saving this resource, they'll get saved alongside it.
export var character: Resource = Character.new()
export var inventory: Resource = Inventory.new()

export var map_name := ""
export var global_position := Vector2.ZERO


# The next three functions are just to keep the save API inside of the SaveGame resource.
# Note that this has safety issues if players download savegame files from the 
# web. Please see the README and check out the deciated video.
# For a safe alternative, see the function write/load_as_json() below.
func write_savegame() -> void:
	ResourceSaver.save(get_save_path(), self)


static func save_exists() -> bool:
	return ResourceLoader.exists(get_save_path())


static func load_savegame() -> Resource:
	var save_path := get_save_path()
	if ResourceLoader.has_cached(save_path):
		# Once the resource caching bug is fixed, you will only need this line of code to load the save game.
		return ResourceLoader.load(save_path, "", true)

	# /!\ Workaround for bug https://github.com/godotengine/godot/issues/59686
	# Without that, sub-resources will not reload from the saved data.
	# We copy the SaveGame resource's data to a temporary file, load that file
	# as a resource, and make it take over the save game.

	# We first load the save game resource's content as text and store it.
	var file := File.new()
	if file.open(save_path, File.READ) != OK:
		printerr("Couldn't read file " + save_path)
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
	# And make it take over the save path for the next time the player
	# saves.
	save.take_over_path(save_path)

	# We delete the temporary file.
	var directory := Directory.new()
	directory.remove(tmp_file_path)
	return save


static func make_random_path() -> String:
	return "user://temp_file_" + str(randi()) + ".tres"


# This function allows us to save and load a text resource in debug builds and a
# binary resource in the released product.
static func get_save_path() -> String:
	var extension := ".tres" if OS.is_debug_build() else ".res"
	return SAVE_GAME_BASE_PATH + extension
