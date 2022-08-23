extends CheckButton




# Called when the node enters the scene tree for the first time.
func _ready():
	connect("toggled", self, "_on_ShowAreas_toggled")
	pressed = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ShowAreas_toggled(value:bool):
	for collision_shape in get_tree().get_nodes_in_group("DebugCollisionShape2D"):
		collision_shape.visible = pressed
