extends Node2D

var _save: SimpleSave = null
var health := 100.0
var coins := 0


func _ready() -> void:
	create_or_load_savegame()
	print_save_data()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_save.health = health
		_save.coins = coins
		_save.write_savegame()
		print_save_data()
	elif event.is_action_pressed("ui_cancel"):
		create_or_load_savegame()
		print_save_data()


func _physics_process(delta: float) -> void:
	health = max(health - delta * 5.0, 0.0)
	coins += 1


func create_or_load_savegame() -> SimpleSave:
	if SimpleSave.save_exists():
		_save = SimpleSave.load_savegame()
	else:
		_save = SimpleSave.new()
		_save.health = 100.0
		_save.coins = 0

	health = _save.health
	coins = _save.coins
	return _save


func print_save_data() -> void:
	print("Health: %.1f | Coins: %d\n\nPress Space to SAVE\nPress Escape to LOAD" % [health, coins])
