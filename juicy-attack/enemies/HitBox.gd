extends Area2D

export var immunity_time := 0.3
export(PackedScene) var damage_label_scene = preload("res://vfx/damage_label/DamageLabel.tscn")

var _previous_hurtbox

onready var _timer = $Timer
onready var _damage_label_pivot = $DamageLabelPivot


func _ready() -> void:
	connect("area_entered", self, "_on_area_entered")
	_timer.connect("timeout", self, "_on_Timer_timeout")


func _on_area_entered(hurtbox: Area2D) -> void:
	if _previous_hurtbox == hurtbox:
		return

	_previous_hurtbox = hurtbox

	if owner.has_method("take_damage"):
		# Signals to Game.gd to slow the game down slightly
		EventBus.emit_signal("enemy_hit")
		var damage = hurtbox.get_damage()
		# Prevents detecting multiple hits from the same area breify
		_timer.start(immunity_time)

		owner.take_damage(damage, hurtbox.global_position)

		# Create damage label
		var damage_label = damage_label_scene.instance()
		damage_label.set_as_toplevel(true)
		add_child(damage_label)
		damage_label.global_position = _damage_label_pivot.global_position
		damage_label.set_damage(damage)


func _on_Timer_timeout() -> void:
	_previous_hurtbox = null
