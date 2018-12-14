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

func _on_Attacked(hp):
	self.hp -= hp
	if self.hp <= 0:
		self.queue_free()

func attack(id):
	emit_signal("attack", self.id, id, damage)

func set_id(id):
	id = id

func get_id():
	return id

func set_state(state):
	if state in Enums.STATUS.keys():
		self.state = state
func get_state():
	return state