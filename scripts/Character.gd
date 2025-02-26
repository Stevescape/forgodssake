extends Node

class_name Character

@export var entity_name: String
@export var max_health: int
@export var dmg: int
@export var defense: int
@export var progressBar: Node
var health = max_health
var textbox
var textbox_closed
var skip_turn = false
var is_dead = false

func _ready() -> void:
	textbox = get_node("/root/Control/Textbox")
	

func take_damage(damage: int):
	var temp = max(0, damage - defense)
	health -= temp
	health = max(0, health)
	await textbox.display_text("%s has taken %d damage." % [entity_name, temp])
	if health <= 0:
		die()
	update_health()

func heal(amount: int):
	health = min(max_health, health+amount)
	await textbox.display_text("%s has healed %d hp." % [entity_name, amount])
	update_health()
	

func display_text(text):
	await textbox.display_text(text)

func die():
	await textbox.display_text("Oh no, %s has died!" % entity_name)
	is_dead = true
	
func update_health():
	progressBar.max_value = max_health
	progressBar.value = health
	progressBar.get_node("Label").text = "HP: %d/%d" % [health, max_health]

func _update_label():
	$PlayerInfo/Data/Label.text = entity_name

func move1(enemy, players):
	pass

func move2(enemy, players):
	pass
	
func attack(enemy, players):
	pass
