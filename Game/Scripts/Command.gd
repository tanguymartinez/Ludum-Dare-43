class_name Command

#Available commands
const commands = {"monster" : [TYPE_INT, TYPE_INT]}

var command setget ,get_command
var args = [] setget ,get_args
var exception

func _init(string):
	var array = string.split(" ")
	if commands.has(array[0]):
		command = array[0]
		array.pop_front()
		for i in range(commands[command].size()):
			args.append(Argument.new(convert(array[0], commands[command][i]), commands[command][i]))
			array.pop_front
	else:
		exception = Exception.new(Enums.EXCEPTIONS.ILLEGAL_COMMAND)

#Command getter
#RETURN Command
func get_command():
	return command

#Args getter
#RETURN Array
func get_args():
	return args