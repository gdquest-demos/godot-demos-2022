extends Area


func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")


func _on_body_entered(body: Node) -> void:
	if body.has_method("reset_position"):
		body.reset_position()
