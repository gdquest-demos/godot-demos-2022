extends "res://weapons/Weapon.gd"

var follow_cursor := true


func use() -> void:
	animation_player.play("slash")


func _physics_process(_delta: float) -> void:
	if follow_cursor:
		look_at(get_global_mouse_position())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("ui_cancel"):
		follow_cursor = !follow_cursor
