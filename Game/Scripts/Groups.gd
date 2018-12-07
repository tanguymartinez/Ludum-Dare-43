class_name Groups

static func get_group_name(key):
	if key in Enums.COLLIDER.keys():
		return key
	return null
	
#Returns TRUE if node is blocking
static func blocking(node):
	for group in node.get_groups():
		if int(group) == Enums.COLLIDER.MAP:
			return false
	return true
