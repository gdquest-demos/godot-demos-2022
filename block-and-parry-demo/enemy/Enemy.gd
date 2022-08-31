extends KinematicBody2D

onready var _hit_box := $Weapon/HitBox
onready var _stun_timer := $StunTimer
onready var _animation_player := $AnimationPlayer


func _ready() -> void:
	_hit_box.connect("area_entered", self, "_on_HitBox_area_entered")
	_stun_timer.connect("timeout", self, "_on_StunTimer_timeout")


func _on_StunTimer_timeout() -> void:
	_animation_player.play("attack")


func _set_stunned() -> void:
	_animation_player.play("stunned")
	_stun_timer.start()


func _on_HitBox_area_entered(area: Area2D) -> void:
	_set_stunned()
