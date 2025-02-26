extends Character

func move1(enemy, players):
	var dmg = 2
	
	await enemy.take_damage(dmg)
	await display_text("Hades Attack")
	
func move2(enemy, players):
	var dmg = 4
	
	await enemy.take_damage(dmg)
	await display_text("Hades Dog")
	
func attack(enemy, players):
	await enemy.take_damage(dmg)
	await display_text("Bident Stab")
