extends Node2D

func _ready() -> void:
	GDQuestVisualizationTools.set_is_debug_collision_visible(false)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen