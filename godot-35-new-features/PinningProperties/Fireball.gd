extends Area2D

export var default_speed := 750.0
export var damage := 1

var max_range := 1000.0
var _travelled_distance = 0.0
onready var speed := default_speed

onready var _animation_player := $AnimationPlayer as AnimationPlayer
onready var _particles := $Particles2D as Particles2D

func _init() -> void:
	set_as_toplevel(true)

func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")
	_animation_player.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")
	_animation_player.play("spawn")

func _on_body_entered(body: Node) -> void:
	hit_body(body)
	_destroy()


func _physics_process(delta: float) -> void:
	var distance := speed * delta
	var motion := transform.x * speed * delta

	position += motion

	_travelled_distance += distance
	if _travelled_distance > max_range:
		_destroy()


func hit_body(_body: Node) -> void:
	_destroy()


func _destroy():
	set_physics_process(false)
	set_deferred("monitoring", false)
	_animation_player.play("destroy")


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "destroy":
		queue_free()
