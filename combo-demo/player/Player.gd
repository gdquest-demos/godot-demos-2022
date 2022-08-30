extends KinematicBody2D

var _accept_next_attack := true
var _previous_light_animation := "light_combo_3"

onready var _animation_player := $AnimationPlayer

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack") and _accept_next_attack:
		_accept_next_attack = false
		
		match _previous_light_animation:
			"light_combo_1":
				_animation_player.play("light_combo_2")
			"light_combo_2":
				_animation_player.play("light_combo_3")
			"light_combo_3":
				_animation_player.play("light_combo_1")
		
		_previous_light_animation = _animation_player.current_animation


func _ready() -> void:
	_animation_player.connect("animation_finished", self, "_on_AnimationPlayer_finished")


func set_accept_next_attack() -> void:
	_accept_next_attack = true
  

func _on_AnimationPlayer_finished(animation_name: String) -> void:
	if "light_combo" in animation_name:
		_previous_light_animation = "light_combo_3"
