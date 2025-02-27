extends Character
var rng = RandomNumberGenerator.new()

@export var mv1_dmg: int = 5
@export var mv2_dmg: int = 4
@export var att_dmg: int = 7

func move1(_enemy, players, targets):
	await display_text("Bark. Everyone takes damage.")
	
	for target in players:
		if not target.is_dead:
			await target.take_damage(mv1_dmg-debuff, false)
	debuff = 0
	
func move2(_enemy, players, targets):
	# First target is enemy, second is ally
	await display_text("Thor spins on you")
	
	for i in targets:
		await players[i].take_damage(mv2_dmg-debuff)
	debuff = 0
	
func attack(_enemy, players, target):
	
	await display_text("Thor smacks you with his biiiiiiig hammer")
	await players[target].take_damage(att_dmg-debuff)
	debuff = 0

func get_image_path():
	return "res://Assets/enemy.png"
