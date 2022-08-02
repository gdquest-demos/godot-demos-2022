extends Node2D

onready var animation_player := $AnimationPlayer

var start_scale := scale
var raycast

func _ready() -> void:
	if Engine.editor_hint or not owner:
		set_physics_process(false)
		return

	yield(owner, "ready")
	for child in owner.get_children():
		if child is RayCast2D:
			raycast = child
			break
	
	if not owner.get("velocity") is Vector2 and not raycast:
		set_physics_process(false)
		printerr("Skin expected a owner node with a velocity property but the owner node doesn't have those. Turning off skin.")
	

func play(animation: String) -> void:
	animation_player.play(animation)


func _physics_process(_delta: float) -> void:
	var horizontal_direction = sign(owner.velocity.x)
	var is_hanging = owner.velocity.y <= 0 and owner.get_slide_count() and abs(owner.velocity.x) <= 5
	if not is_zero_approx(horizontal_direction):
		scale.x = sign(horizontal_direction) * start_scale.x

	if is_hanging:
		play("hang")
	else:
		play("fly")
