class_name Entity
extends AnimatedSprite

signal attack(sender, receiver, damage)

export(int, 0, 100) var mana
export(int, 0, 100) var hp
var id

func _ready():
	self.add_to_group(str(Enums.COLLIDER.ENEMY))

func attacked(hp):
	self.hp -= hp
	if self.hp <= 0:
		self.queue_free()

func attack(id, damage):
	emit_signal("attack", id, damage)

func move(dir):
	pass
