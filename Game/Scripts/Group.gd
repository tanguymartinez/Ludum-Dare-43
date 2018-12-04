enum Possibilities{NON_BLOCKING, ENNEMY, ALLY}
var groups = {NON_BLOCKING : 0, ENNEMY : 1, ALLY : 2}
var group setget ,get_group

func _init(grp):
	if groups.has(grp):
		group = groups[grp]
	else:
		print("Wrong group!")
		group = null
func get_group():
	return group