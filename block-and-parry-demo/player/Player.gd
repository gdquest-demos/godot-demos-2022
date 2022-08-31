extends KinematicBody2D

var blocking := false

onready var _hurt_box := $HurtBox
onready var _block_box := $BlockBox
onready var _parry_timer := $ParryTimer

onready var _move_animation_player := $MoveAnimationPlayer
onready var _damage_animation_player := $DamageAnimationPlayer


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("block"):
		_block_start()
	
	if event.is_action_released("block"):
		_block_end()


func _ready() -> void:
	_block_box.connect("area_entered", self, "take_block_hit")


func take_damage(damage: int) -> void:
	_damage_animation_player.play("take_damage")


func take_block_hit() -> void:
	_damage_animation_player.play("take_block_damage")


func _block_start() -> void:
	_parry_timer.start()
	_block_box.set_deferred("monitoring", true)
	_move_animation_player.play("block")


func _block_end() -> void:
	_block_box.set_deferred("monitoring", false)
	_move_animation_player.play("idle")
