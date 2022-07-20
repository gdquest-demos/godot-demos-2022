extends Node


var is_debug_collision_visible := true setget set_is_debug_collision_visible
var is_debug_navigation_visible := true setget set_is_debug_navigation_visible


func _ready() -> void:
	set_is_debug_collision_visible(is_debug_collision_visible)
	set_is_debug_navigation_visible(is_debug_navigation_visible)


func set_is_debug_collision_visible(new_is_debug_collision_visible: bool) -> void:
	is_debug_collision_visible = new_is_debug_collision_visible
	get_tree().call_group("GVTCollision", "set_visible", is_debug_collision_visible)


func set_is_debug_navigation_visible(new_is_debug_navigation_visible: bool) -> void:
	is_debug_navigation_visible = new_is_debug_navigation_visible
	get_tree().call_group("GVTNavigation", "set_visible", is_debug_navigation_visible)
