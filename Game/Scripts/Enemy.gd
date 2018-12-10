class_name Enemy
extends AnimatedSprite

enum TYPES{RED, BLUE, GREEN,YELLOW}
const MONSTERS = {"red" : "Drops weapons when killed", "blue" : "Boosts the player's actions when killed", "green" : "Drops resources when killed", "yellow" : "Drops gold when kiled"}
export(int) var MAX_HP
var hp
var type setget set_type,get_type

func _ready():
	self.add_to_group(str(Enums.COLLIDER.ENEMY))
	hp = MAX_HP

func attacked(hp):
	self.hp -= hp
	if self.hp <= 0:
		self.queue_free()

func move(dir):
	pass

func set_type(monster_type):
	if monster_type in TYPES.values():
		type = monster_type

func get_type():
	return type