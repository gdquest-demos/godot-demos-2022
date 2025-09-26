# Save and load the game using the text or binary resource format.
#
# /!\ This approach is unsafe if players download completed save games from the
# web. Please read the README and watch the corresponding video about security
# issues.
class_name SaveGameAsResource extends Resource

# You must use the user:// path prefix when saving the player's data.
#
# We removed the extension in this demo to show how to save as text during
# development or in debug builds and binary in the released game.
#
# See the get_save_path() function below.
const SAVE_GAME_BASE_PATH := "user://save"

# Use this to detect old player saves and update their data.
@export var version := 1

# We directly reference the characters stats and inventory in the save game resource.
# When saving this resource, they'll get saved alongside it.
@export var character: Resource = Character.new()
@export var inventory: Resource = Inventory.new()

@export var map_name := ""
@export var global_position := Vector2.ZERO


# The next three functions are just to keep the save API inside of the SaveGameAsResource resource.
# Note that this has safety issues if players download savegame files from the
# web. Please see the README and check out the dedicated video.
# For a safe alternative, see the function write/load_as_json() below.
func write_savegame() -> void:
	ResourceSaver.save(self, get_save_path())


static func save_exists() -> bool:
	return ResourceLoader.exists(get_save_path())


static func load_savegame() -> Resource:
	var save_path := get_save_path()
	return ResourceLoader.load(save_path, "", ResourceLoader.CACHE_MODE_IGNORE)


# This function allows us to save and load a text resource in debug builds and a
# binary resource in the released product.
static func get_save_path() -> String:
	var extension := ".tres" if OS.is_debug_build() else ".res"
	return SAVE_GAME_BASE_PATH + extension
