extends Character

class_name Poseidon

func move1(enemy, players):
	var dmg = 2
	var heal = 3
	# First target is enemy, second is ally
	await display_text("Water")
	
	var ally: Character = players[1]
	
	await enemy.take_damage(dmg)
	await ally.heal(heal)
	
func move2(enemy, players):
	var dmg = 6
	skip_turn = true
	
	await display_text("Tsunami")
	await enemy.take_damage(dmg)
	
	
func attack(enemy, players):
	
	await display_text("Stab")
	await enemy.take_damage(dmg)
