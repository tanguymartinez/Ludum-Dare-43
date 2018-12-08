class_name Exception
extends Object

var exception setget ,get_exception
const description = [
	"You typed a command which doesn't exist!",
	"Arguments aren't conform to the specifications!",
	"You supplied the wrong numbers of arguments!",
	"Maybe try to write something before sending?"
]

func _init(exception):
	if exception in Enums.EXCEPTIONS.values():
		self.exception = exception

func get_description():
	return description[exception]

func get_exception():
	return exception