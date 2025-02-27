extends Node

var selected_characters = []
var cur_slot = 0

var battle = preload("res://Scenes/battle.tscn")

@rpc("authority", "call_local", "reliable")
func swap_scene():
	$MultiplayerSpawner.add_spawnable_scene("res://Scenes/battle.tscn")
	get_tree().current_scene.queue_free()

	var instances_scene = battle.instantiate()

	get_tree().root.add_child(instances_scene)

	get_tree().current_scene = instances_scene
		

@rpc("any_peer", "call_local", "reliable")
func assign_character(character_script):
	CharacterSelect.selected_characters.append(character_script)
	print(CharacterSelect.selected_characters)
	

@rpc("any_peer", "call_local", "reliable")
func disable_button(button_path):
	var button = get_node(button_path)
	button.disabled = true
	
	cur_slot += 1
	
	$Panel/VBoxContainer/Label.text = "Select Your Character Player %d" % (cur_slot+1)
	
	print("Adding character, now on player %d" % cur_slot)
	if cur_slot >= 4:
		print("Swapping scene")
		swap_scene.rpc()
	
@rpc("any_peer", "reliable")
func _on_poseidon_pressed() -> void:
	assign_character.rpc("res://Scripts/Poseidon.gd")
	disable_button.rpc("Panel/VBoxContainer/HBoxContainer/Poseidon")

@rpc("any_peer", "reliable")
func _on_hades_pressed() -> void:
	assign_character.rpc("res://Scripts/Hades.gd")
	disable_button.rpc("Panel/VBoxContainer/HBoxContainer/Hades")
	
@rpc("any_peer", "reliable")
func _on_isis_pressed() -> void:
	assign_character.rpc("res://Scripts/Isis.gd")
	disable_button.rpc("Panel/VBoxContainer/HBoxContainer/Isis")

@rpc("any_peer", "reliable")
func _on_odin_pressed() -> void:
	assign_character.rpc("res://Scripts/Odin.gd")
	disable_button.rpc("Panel/VBoxContainer/HBoxContainer/Odin")
