extends Area2D

export var immunity_time := 0.3

var _previous_hurtbox

onready var _timer = $Timer


func _ready() -> void:
	connect("area_entered", self, "_on_area_entered")
	_timer.connect("timeout", self, "_on_Timer_timeout")


func _on_area_entered(hurtbox: Area2D) -> void:
	
	if _previous_hurtbox == hurtbox:
		return
	
	_previous_hurtbox = hurtbox
	
	if owner.has_method("take_damage"):
		_timer.start(immunity_time)
		EventBus.emit_signal("enemy_hit")
		owner.take_damage(hurtbox.damage, hurtbox.global_position)


func _on_Timer_timeout() -> void:
	_previous_hurtbox = null
