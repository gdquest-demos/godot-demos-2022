extends Node


# Maps unique IDs of items to ItemData instances.
var ITEMS := {}


func _ready() -> void:
	var items := _load_items()
	for item in items:
		ITEMS[item.unique_id] = item


func get_item_data(unique_id: String) -> ItemData:
	if not unique_id in ITEMS:
		printerr("Trying to get nonexistent item %s in items database" % unique_id)
		return null
	
	return ITEMS[unique_id]


static func _load_items() -> Array:
	var item_files := []
	var items_folder := "res://resources/items"

	var directory := Directory.new()
	var can_continue := directory.open(items_folder) == OK
	if not can_continue:
		print_debug('Could not open directory "%s"' % [items_folder])
		return item_files

	directory.list_dir_begin(true, true)
	var file_name := directory.get_next()
	while file_name != "":
		if file_name.get_extension() == "tres":
			item_files.append(items_folder.plus_file(file_name))
		file_name = directory.get_next()

	var item_resources := []
	for path in item_files:
		item_resources.append(load(path))

	# Ensure each loaded item has valid data in debug builds.
	if OS.is_debug_build():
		var ids := []
		var bad_items := []
		for item in item_resources:
			if item.unique_id in ids:
				bad_items.append(item)
			else:
				ids.append(item.unique_id)
		for item in bad_items:
			printerr("Item %s has a non-unique ID: %s" % [item.display_name, item.unique_id])

	return item_resources
