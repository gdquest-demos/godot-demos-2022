extends Node2D

var follow_cursor := true

onready var _animation_player := $AnimationPlayer


func use() -> void:
	_animation_player.play("slash")


func _physics_process(_delta: float) -> void:
	if follow_cursor:
		look_at(get_global_mouse_position())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("ui_cancel"):
		follow_cursor = !follow_cursor
	
	if event.is_action_pressed("attack"):
		use()
