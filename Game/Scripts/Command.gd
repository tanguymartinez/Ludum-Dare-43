class_name Command

#Available commands
const commands = {
	#name : [args_types, "check_function_name", "description", whether_to_exec_locally]
	"monster" : [TYPE_INT, TYPE_INT, "monster_check", "Spawns a normal monster at the specified \"x y\" location", false],
	"help" : [TYPE_STRING, "help_check", "Help <command_name>", true]
}

var command setget ,get_command
var args = [] setget ,get_args
var exception
var description
var local

#Constructor, where the magic happens!
func _init(string):
	if string.empty(): #If the string is empty
		exception = Exception.new(Enums.EXCEPTIONS.EMPTY)
		return
	var array = string.split(" ")
	if commands.has(array[0]): #If command exists
		command = array[0]
		array.remove(0)
		description = commands[command][commands[command].size()-2] #Set description
		local = commands[command][commands[command].size()-1] #Set whether local or not
		if array.size() == 0: #If no arguments supplied
			for i in range(commands[command].size()-3): #Loop over the arguments
				args.append(Argument.new(convert(0, commands[command][i]), commands[command][i])) #Insert argument in args
			exception = Exception.new(Enums.EXCEPTIONS.MISSING_ARGUMENTS) #Fill exception
		else: #Else (if arguments supplied)
			for i in range(commands[command].size()-3): #Loop over the arguments
				args.append(Argument.new(convert(array[0], commands[command][i]), commands[command][i])) #Insert argument in args
				array.remove(0) #Remove head
			if not callv(commands[command][commands[command].size()-3], args): #If specific check unvalidate params
				exception = Exception.new(Enums.EXCEPTIONS.ILLEGAL_ARGUMENTS)
				return
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

func is_local():
	return local


#Commands checks

#Checks that supplied coordinates correspond to the map
func monster_check(x, y):
	if in_bounds(Vector2(y.value,x.value), Variables.GRID_HEIGHT, Variables.GRID_WIDTH):
		return true
	return false

func help_check(string):
	if commands.has(string.value):
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

