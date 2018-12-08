class_name Exception
extends Object

var exception setget ,get_exception
const description = [
	"You typed a command which doesn't exist!"
]

func _init(exception):
	if Enums.EXCEPTIONS.has(exception):
		self.exception = exception

func get_description():
	return description[exception]

func get_exception():
	return exception