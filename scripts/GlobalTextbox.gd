extends Node

func _ready() -> void:
	pass

func display_text(text):
	var textbox = get_node("/root/Control/Textbox")

	textbox.show()
	textbox.get_node("Label").text = text
	await get_tree().create_timer(0.5).timeout
	await GlobalSignal.close_box

	textbox.hide()
	
