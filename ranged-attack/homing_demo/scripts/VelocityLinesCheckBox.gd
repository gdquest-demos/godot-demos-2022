extends CheckBox


func _ready():
	connect("toggled", self, "_on_toggled")
	pressed = true


func _on_toggled(value: bool):
	GDQuestVisualizationTools.set_is_debug_navigation_visible(value)
