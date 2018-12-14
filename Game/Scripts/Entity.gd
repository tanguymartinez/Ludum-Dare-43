class_name Entity
extends AnimatedSprite

export(int, 0, 100) var mana
export(int, 0, 100) var hp

func _ready():
	self.add_to_group(str(Enums.COLLIDER.ENEMY))

func attacked(hp):
	self.hp -= hp
	if self.hp <= 0:
		self.queue_free()

func move(dir):
	pass
