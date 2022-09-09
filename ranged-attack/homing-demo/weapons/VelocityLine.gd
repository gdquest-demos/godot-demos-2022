extends Line2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = GDQuestVisualizationTools.is_debug_navigation_visible


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
