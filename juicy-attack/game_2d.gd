extends Node2D

@export var freeze_slow := 0.07
@export var freeze_time := 0.3

@onready var scarecrows: Node2D = %Scarecrows2D


func _ready() -> void:
	for scarecrow: CharacterBody2D in scarecrows.get_children():
		scarecrow.hit.connect(freeze_engine)


func freeze_engine() -> void:
	Engine.time_scale = freeze_slow
	await get_tree().create_timer(freeze_time * freeze_slow).timeout
	Engine.time_scale = 1.0
