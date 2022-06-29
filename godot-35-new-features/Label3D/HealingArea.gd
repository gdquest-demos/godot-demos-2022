extends Area


func _ready() -> void:
	connect("body_entered", self, "_on_body", [true])
	connect("body_exited", self, "_on_body", [false])


func _on_body(body: Node, entered: bool) -> void:
	if 'is_healing' in body:
		body.is_healing = entered
