class_name Exception

var exception
const description = [
	"You typed a command which doesn't exist!"
]

func _init(exception):
	if Enums.EXCEPTIONS.has(exception):
		self.exception = exception

func get_description():
	return description[exception]