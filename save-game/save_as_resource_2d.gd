# Takes care of loading or creating a new save game and provides appropriate
# resources to the user interface and the player.
extends Node2D

# We always keep a reference to the SaveGameAsResource resource here to prevent it from unloading.
var _save := SaveGameAsResource.new()

@onready var _player: CharacterBody2D = %Player2D
@onready var _info_panel_container: PanelContainer = %InfoPanelContainer
@onready var _save_panel: Panel = %SavePanel
@onready var _inventory_panel: Panel = %InventoryPanel


func _ready() -> void:
	_save_panel.reload_requested.connect(_create_or_load_save)
	_save_panel.save_requested.connect(_save_game)

	# And the start of the game or when pressing the load button, we call this
	# function. It loads the save data if it exists, otherwise, it creates a
	# new save file.
	_create_or_load_save()
	# This function offsets the camera when the inventory menu is open to not
	# hide the player.
	_player.toggle_camera_offset(_inventory_panel.visible)


# Toggles the inventory's visibility when pressing I.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		if not _inventory_panel.visible:
			_inventory_panel.show()
		else:
			_inventory_panel.hide()
		_player.toggle_camera_offset(_inventory_panel.visible)


func _physics_process(_delta: float) -> void:
	_info_panel_container.update_player_position(_player.global_position)


func _create_or_load_save() -> void:
	if SaveGameAsResource.save_exists():
		_save = SaveGameAsResource.load_savegame()
	else:
		_save = SaveGameAsResource.new()
		_save.inventory.add_item("healing_gem", 3)
		_save.inventory.add_item("sword", 1)

		_save.map_name = "map_1"
		_save.global_position = _player.global_position

		_save.write_savegame()

	# After creating or loading a save resource, we need to dispatch its data
	# to the various nodes that need it.
	_player.global_position = _save.global_position
	_inventory_panel.inventory = _save.inventory
	_player.stats = _save.character
	_info_panel_container.character = _save.character


func _save_game() -> void:
	_save.global_position = _player.global_position
	_save.write_savegame()
