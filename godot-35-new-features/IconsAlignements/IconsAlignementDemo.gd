extends Control

const alignements := {
	"left": Button.ALIGN_LEFT,
	"center": Button.ALIGN_CENTER,
	"right": Button.ALIGN_RIGHT
}

onready var titles_alignement: OptionButton = get_node("%TitlesAlignement")
onready var buttons_alignement: OptionButton = get_node("%ButtonsAlignement")

onready var groups := {
	titles_alignement: "title",
	buttons_alignement: "button"
}

func _ready() -> void:
	for option_button in groups:
		for alignement_name in alignements:
			var idx: int = alignements[alignement_name]
			option_button.add_item(alignement_name, idx)
		var group: String = groups[option_button]
		option_button.selected = get_tree().get_nodes_in_group(group)[0].icon_align
		option_button.connect("item_selected", self, "_on_alignement_changed", [ group ])


func _on_alignement_changed(idx: int, group: String) -> void:
	var buttons := get_tree().get_nodes_in_group(group)
	for index in buttons.size():
		var button: Button = buttons[index]
		button.icon_align = idx
