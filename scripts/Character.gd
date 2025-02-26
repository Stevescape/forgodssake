extends Node

class_name Character

@export var entity_name: String
@export var max_health: int
@export var defense: int
@export var progressBar: Node
var health 
var textbox
var textbox_closed
var skip_turn = false
var is_dead = false
var animPlayer

func _ready() -> void:
	textbox = get_node("/root/Control/Textbox")
	animPlayer = get_node("/root/Control/AnimationPlayer")
	health = max_health
	update_health()

func take_damage(damage: int, show_textbox=true):
	var temp = max(0, damage - defense)
	health -= temp
	health = max(0, health)
	await update_health()
	if show_textbox:
		await textbox.display_text("%s has taken %d damage." % [entity_name, temp])
	if health <= 0:
		await die()

func heal(amount: int):
	health = min(max_health, health+amount)
	await textbox.display_text("%s has healed %d hp." % [entity_name, amount])
	await update_health()
	

func display_text(text):
	await textbox.display_text(text)

func die():
	await textbox.display_text("Oh no, %s has died!" % entity_name)
	is_dead = true
	
func update_health():
	progressBar.max_value = max_health
	progressBar.value = health
	progressBar.get_node("Label").text = "HP: %d/%d" % [health, max_health]

func _update_label(is_enemy=false):
	if is_enemy:
		$Data/Label.text = entity_name
	else:
		$PlayerInfo/Data/Label.text = entity_name

func play_animation(animation):
	animPlayer.play(animation)
	await animPlayer.animation_finished

func move1(enemy, players, targets):
	pass

func move2(enemy, players, targets):
	pass
	
func attack(enemy, players, targets):
	pass
