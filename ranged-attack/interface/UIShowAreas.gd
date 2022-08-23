extends CheckButton


func _ready():
	connect("toggled", self, "_on_ShowAreas_toggled")
	pressed = true

func _on_ShowAreas_toggled(value:bool):
	GDQuestVisualizationTools.set_is_debug_collision_visible(value)
