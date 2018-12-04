var groups = {"NonBlocking" : 0, "Ennemy" : 1, "Ally" : 2}
var group setget ,get_group

func _init(grp):
	if groups.has(grp):
		group = groups[grp]
	else:
		print("Wrong group!")
		group = null
func get_group():
	return group