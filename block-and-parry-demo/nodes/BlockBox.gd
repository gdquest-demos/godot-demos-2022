extends Area2D

var parrying := false


func _ready() -> void:
	connect("area_entered", self, "_on_area_entered")
