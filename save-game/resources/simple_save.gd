# A minimal example of saving data with resources.
# This shows how to save just a couple of simple values: health and coins.
class_name SimpleSave
extends Resource

const SAVE_PATH := "user://simple_save.tres"

@export var health := 100.0
@export var coins := 0


func write_savegame() -> void:
	ResourceSaver.save(self, SAVE_PATH)


static func save_exists() -> bool:
	return ResourceLoader.exists(SAVE_PATH)


static func load_savegame() -> SimpleSave:
	return ResourceLoader.load(SAVE_PATH, "", ResourceLoader.CACHE_MODE_IGNORE)
