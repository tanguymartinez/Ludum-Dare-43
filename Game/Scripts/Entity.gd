class_name Entity
extends AnimatedSprite

signal attack(sender, receiver, damage)

export(int, 0, 100) var mana
export(int, 0, 100) var hp
export(int, 0, 100) var damage
var state setget set_state,get_state

var id setget set_id, get_id

func _ready():
	state = Enums.STATUS.IDLE
	self.add_to_group(str(Enums.COLLIDER.ENEMY))

func attacked(hp):
	self.hp -= hp
	if self.hp <= 0:
#		self.queue_free() #Would mess the references system since the references dict would resize
		return true
	return false

func attack(id):
	emit_signal("attack", self.id, id, damage)

func set_id(id_arg):
	id = id_arg

func get_id():
	return id

func set_state(s):
	if s in range(Enums.STATUS.size()):
		state = s
func get_state():
	return state