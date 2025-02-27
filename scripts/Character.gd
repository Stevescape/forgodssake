extends Node

class_name Character

@export var entity_name: String = "Temp"
@export var max_health: int = 10
var progressBar
var health 
var textbox
var skip_turn = false
var is_dead = false
var animPlayer

var shield: int = 0
var debuff: int = 0
var buff: int = 0

func _ready() -> void:
	textbox = get_node("/root/Control/Textbox")
	animPlayer = $AnimationPlayer
	progressBar = $PlayerInfo/Data/ProgressBar
	health = max_health
	update_health()

func take_damage(damage: int, show_textbox=true, bypass_shield=false):
	var temp = max(0, damage - shield)
	if bypass_shield:
		temp = max(0, damage)
	else:
		shield = 0
	health -= temp
	health = max(0, health)
	await play_animation("take_damage")
	await update_health()
	if show_textbox:
		await textbox.display_text("%s has taken %d damage." % [entity_name, temp])
	if health <= 0:
		await die()

func heal(amount: int):
	health = min(max_health, health+amount)
	await play_animation("heal")
	await textbox.display_text("%s has healed %d hp." % [entity_name, amount])
	await update_health()
	
func shielded(amount: int):
	shield = amount
	await play_animation("shield")
	await textbox.display_text("%s has been shielded, blocking %d damage." % [entity_name, amount])
	await update_health()
	
@rpc ("authority", "call_local", "reliable")
func display_text(text):
	await textbox.display_text(text)

func die():
	await textbox.display_text("Oh no, %s has died!" % entity_name)
	is_dead = true
	
func update_health():
	progressBar.max_value = max_health
	progressBar.value = health
	if shield == 0:
		progressBar.get_node("Label").text = "HP: %d/%d" % [health, max_health]
	else:
		progressBar.get_node("Label").text = "HP: %d/%d Shield: %d" % [health, max_health, shield]

func _update_label(is_enemy=false):
	if is_enemy:
		$PlayerInfo/Data/Label.text = entity_name
	else:
		$PlayerInfo/Data/Label.text = entity_name

func play_animation(animation):
	animPlayer.play(animation)
	await animPlayer.animation_finished
	await get_tree().create_timer(0.1).timeout

func put_tooltips(player):
	pass

func move1(enemy, players, targets):
	pass

func move2(enemy, players, targets):
	pass
	
func attack(enemy, players, targets):
	pass
	
func get_image_path():
	pass	

func load_image(image_path):
	var image = load(image_path)
	$TextureRect.texture = image
