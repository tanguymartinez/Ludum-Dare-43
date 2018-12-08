class_name Command

#Available commands
const commands = {"monster" : [TYPE_INT, TYPE_INT, "monster_check"]}

var command : String setget ,get_command
var args = [] setget ,get_args
var exception

func _init(string):
	var array = string.split(" ")
	if commands.has(array[0]):
		command = array[0]
		array.remove(0)
		for i in range(commands[command].size()-1):
			args.append(Argument.new(convert(array[0], commands[command][i]), commands[command][i]))
			array.remove(0)
		if not callv(commands[command][commands[command].size()-1], args):
			exception = Exception.new(Enums.EXCEPTIONS.ILLEGAL_ARGUMENTS)
	else:
		exception = Exception.new(Enums.EXCEPTIONS.ILLEGAL_COMMAND)

#Command getter
#RETURN String
func get_command():
	return command

#Args getter
#RETURN Array
func get_args():
	return args
	
func monster_check(x, y):
	if in_bounds(Vector2(y.value,x.value), Variables.GRID_HEIGHT, Variables.GRID_WIDTH):
		return true
	return false
	
#Checks whether the position supplied is in the grid of width <width> and height <height>
#PARAM pos : Vector2
#PARAM width : int
#PARAM height : int
#RETURN bool
func in_bounds(pos, width, height):
	if 0 <= pos.x and pos.x < width and 0 <= pos.y and pos.y < height:
		return true
	return false
