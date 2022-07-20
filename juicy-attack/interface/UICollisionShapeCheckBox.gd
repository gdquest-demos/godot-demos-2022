extends CheckBox


func _ready() -> void:
	connect("toggled", self, "_on_toggled")


func _on_toggled(toggled: bool) -> void:
	get_tree().call_group("GVTCollision", "set_visible", toggled)
