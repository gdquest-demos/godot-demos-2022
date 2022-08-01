extends KinematicBody2D

export var max_speed := 300.0
export var drag_factor := 0.1

var velocity := Vector2.ZERO
var target

onready var raycast := $RayCast2D
onready var aggro_area := $AggroArea


func _ready() -> void:
	aggro_area.connect("body_entered", self, "_on_player_entered")
	aggro_area.connect("body_exited", self, "_on_player_exited")


func _physics_process(delta: float) -> void:
	var direction := Vector2.UP
	if target:
		raycast.look_at(target.global_position)
		raycast.force_raycast_update()
		if raycast.get_collider() == target:
			direction = to_local(target.global_position).normalized()

	var desired_velocity := max_speed * direction
	var steering_vector := desired_velocity - velocity
	velocity += steering_vector * drag_factor
	
	velocity = move_and_slide(velocity)


func _on_player_entered(player: KinematicBody2D) -> void:
	target = player


func _on_player_exited(player: KinematicBody2D) -> void:
	target = null
