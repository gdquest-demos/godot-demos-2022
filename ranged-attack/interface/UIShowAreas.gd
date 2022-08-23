extends CheckBox


func _ready():
	connect("toggled", self, "_toggled")
	pressed = true

func _toggled(value:bool):
	GDQuestVisualizationTools.set_is_debug_collision_visible(value)
