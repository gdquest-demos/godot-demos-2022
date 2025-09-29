extends Node2D

var _save: SimpleSave = null


func _ready() -> void:
	_create_or_load_savegame()
	_update_label()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_save.write_savegame()
		_update_label()
	elif event.is_action_pressed("ui_cancel"):
		_create_or_load_savegame()
		_update_label()


func _physics_process(delta: float) -> void:
	_save.health = max(_save.health - delta * 5.0, 0.0)
	_save.coins += 1
	_update_label()


func _create_or_load_savegame() -> SimpleSave:
	if SimpleSave.save_exists():
		return SimpleSave.load_savegame()
	else:
		var save := SimpleSave.new()
		save.health = 100.0
		save.coins = 0
		return save


func _update_label() -> void:
	print("Health: %.1f | Coins: %d\n\nPress Space to SAVE\nPress Escape to LOAD" % [_save.health, _save.coins])
