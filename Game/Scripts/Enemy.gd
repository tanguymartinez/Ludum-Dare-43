class_name Enemy
extends AnimatedSprite

func _ready():
	self.add_to_group(str(Enums.COLLIDER.ENEMY))
