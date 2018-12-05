class_name Groups
extends Node2D
enum COLLIDER{ENNEMY, ALLY, PART}
enum FREE{}

func _ready():
	pass
	
static func get_group_name(key):
	if key in (COLLIDER.keys() or FREE.keys()):
		return key
	return null
	
static func empty(node):
	for group in node.get_groups():
		if int(group) in COLLIDER.values():
			return false
	return true
