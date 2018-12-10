class_name Command

#Available commands
const commands = {
	#name : [args_types, "check_function_name", "description", whether_to_exec_locally]
	"monster" : [TYPE_INT, TYPE_INT, TYPE_STRING, "monster_check", "Spawns a <type> monster at the specified \"x y\" location", false],
	"move" : [TYPE_INT, TYPE_INT, TYPE_INT, "move_check", "Moves the monster of id <id> of \"x y\" tiles", false],
	"help" : [TYPE_STRING, "help_check", "Displays an insightful help message about the <command_name> you supplied as parameter", true],
	"list" : ["list_check", "List all available commands", true],
	"uname" : ["uname_check", "Displays the name of the host OS", true]
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
			if commands[command].size() <= 3: #If command does not require any argument
				pass
			else: #Command required arguments
				for i in range(commands[command].size()-3): #Loop over the arguments
					args.append(Argument.new(convert("", commands[command][i]), commands[command][i])) #Insert argument in args
				exception = Exception.new(Enums.EXCEPTIONS.MISSING_ARGUMENTS) #Fill exception
		else: #Else (if arguments supplied)
			for i in range(commands[command].size()-3): #Loop over the arguments
				if array.size() == 0: #Arguments were not all present
					exception = Exception.new(Enums.EXCEPTIONS.MISSING_ARGUMENTS)
					return
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
#PARAM x : Arg(int)
#PARAM y : Arg(int)
#PARAM type : Arg(String)
func monster_check(x, y, type):
	if in_bounds(Vector2(y.value,x.value), Variables.GRID_HEIGHT, Variables.GRID_WIDTH) and Enemy.MONSTERS.has(type.value):
		print("passed monster check")
		return true
	return false

#Checks that supplied coordinates correspond to the map and that id is valid
#PARAM id : Arg(int)
#PARAM x : Arg(int)
#PARAM y : Arg(int)
func move_check(id, x, y):
	if in_bounds(Vector2(y.value,x.value), Variables.GRID_HEIGHT, Variables.GRID_WIDTH):
		return true
	return false

#Checks whether the string is a valid command
#PARAM string : Arg(String)
func help_check(string):
	if commands.has(string.value):
		return true
	return false

#Checks whether the command is valid
#PARAM string : Arg(Nil)
func list_check():
	return true

#Checks whether the position supplied is in the grid of width <width> and height <height>
#PARAM pos : Vector2
#PARAM width : int
#PARAM height : int
#RETURN bool
func in_bounds(pos, width, height):
	if 0 <= pos.x and pos.x < width and 0 <= pos.y and pos.y < height:
		return true
	return false
