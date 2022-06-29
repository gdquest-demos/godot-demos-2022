extends Camera

export var decay := 2
export var max_offset := 0.01

var shake_factor := 0.0 setget set_shake_factor
var shake_factor_power := 1.2

func shake() -> void:
	set_shake_factor(1)


func set_shake_factor(amount := 1.0) -> void:
	shake_factor = min(shake_factor + amount, 1.0)


func _process(delta: float) -> void:
	if shake_factor < 0.001:
		return
	shake_factor = max(shake_factor - decay * delta, 0)
	var amount := (shake_factor * shake_factor_power)
	v_offset = max_offset * amount * rand_range(-1, 1)
	h_offset = max_offset * amount * rand_range(-1, 1)
