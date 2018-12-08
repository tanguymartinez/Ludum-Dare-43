class_name Argument

var value setget ,get_value
var type setget ,get_type

func _init(value, type):
	if typeof(value) == type:
		self.value = value
		self.type = type
	else:
		print("Failed building argument, type mismatch...")

func get_value():
	return value

func get_type():
	return type