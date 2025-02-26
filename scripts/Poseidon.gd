extends Character

class_name Poseidon

@export var mv1_dmg: int = 2
@export var mv1_heal: int = 3
@export var mv2_dmg: int = 8
@export var att_dmg: int = 4

func move1(enemy, players, targets):
	# First target is enemy, second is ally
	await display_text("Water")
	
	await enemy.take_damage(mv1_dmg)
	await targets.heal(mv1_heal)
	
	
func move2(enemy, players, targets):
	skip_turn = true
	
	await display_text("Tsunami")
	
	await play_animation("tsunami")
	
	await enemy.take_damage(mv2_dmg)
	
	
	
func attack(enemy, players, targets):
	await display_text("Stab")
	await enemy.take_damage(att_dmg)
