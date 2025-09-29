class_name ItemPanel
extends Panel

signal tooltip_requested

var item_unique_id := ""

@onready var tooltip_timer: Timer = %TooltipTimer
@onready var texture_rect: TextureRect = %TextureRect
@onready var amount_label: Label = %AmountLabel
@onready var name_label: Label = %NameLabel


func _ready() -> void:
	mouse_entered.connect(tooltip_timer.start)
	mouse_exited.connect(tooltip_timer.stop)
	tooltip_timer.timeout.connect(_request_tooltip)


func _request_tooltip() -> void:
	if not item_unique_id.is_empty():
		tooltip_requested.emit()


func display_item(unique_id: String, amount: int) -> void:
	item_unique_id = unique_id
	var data := ItemDatabase.get_item_data(unique_id)
	texture_rect.texture = data.icon
	name_label.text = data.display_name
	amount_label.text = str(amount).pad_zeros(2)
