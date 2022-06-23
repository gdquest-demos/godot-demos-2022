extends Node2D

var _save: SaveGame

onready var _player := $PlayerCharacter
onready var _ui_inventory := $UI/UIInventory
onready var _ui_save_panel := $UI/UISavePanel
onready var _ui_info_display := $UI/UIInfoDisplay


func _ready() -> void:
	_ui_save_panel.connect("reload_requested", self, "_create_or_load_save")
	_ui_save_panel.connect("save_requested", self, "_save_game")
	_create_or_load_save()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		if not _ui_inventory.visible:
			_ui_inventory.show()
		else:
			_ui_inventory.hide()
		_player.toggle_camera_offset(_ui_inventory.visible)


func _physics_process(delta: float) -> void:
	_ui_info_display.update_player_position(_player.global_position)


func _create_or_load_save() -> void:
	if SaveGame.save_exists():
		_save = SaveGame.load_savegame() as SaveGame
	else:
		_save = SaveGame.new()

		_save.inventory = Inventory.new()
		_save.inventory.add_item("healing_gem", 3)
		_save.inventory.add_item("sword", 1)

		_save.character = Character.new()
		_save.map_name = "map_1"
		_save.global_position = _player.global_position

		_save.write_savegame()

	_player.global_position = _save.global_position
	_ui_inventory.inventory = _save.inventory
	_player.stats = _save.character
	_ui_info_display.character = _save.character


func _save_game() -> void:
	_save.global_position = _player.global_position
	_save.write_savegame()
