class_name Argument

var value
var type

func _init(value, type):
	if typeof(value) == type:
		self.value = value
		self.type = type
	else:
		print("Failed building argument, type mismatch...")