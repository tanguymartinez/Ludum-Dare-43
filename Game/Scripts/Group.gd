var groups = {"NonBlocking" : 0, "Ennemy" : 1, "Ally" : 2}
var group setget ,get_group

func _init(grp):
	for group in groups:
		if groups[group] == grp:
			self.group = group
		else:
			print("Wrong group supplied!")
			self.group = null
			
func get_group():
	return group