extends Node2D
#Constants
const SERVER_PORT = 1337
const MAX_PLAYERS = 1

#CLI related
var text = []

#Player related
var player_id
var player_ip_address

#Monsters related
puppet var references = {
	#id : {"node" : <node>, ...properties]
}

#Game related
var playing

func _ready():
	
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	# Called when the node is added to the scene for the first time.
	# Initialization here
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	
	get_tree().set_network_peer(peer)
	text.append("Server's ip address: ")
	for address in IP.get_local_addresses():
		if(not ":" in address):
			text.append(address)
	refresh()

#Signal handler triggered when the player connects
#PARAM id : int
func _player_connected(id):
	player_id = id
	print_text("Player "+ str(id) +" is connected...")

#Signal handler triggered when the player disconnects
#PARAM id : int
func _player_disconnected(id):
	print_text("Player disconnected...") # Erase player from info

#Refreshes the CLI display
func refresh():
	var string = ""
	for line in text:
		string += line + "\n"
	$"GUI/CLI".bbcode_text = string

#Prints the <string> to the CLI
#PARAM string : String
func print_text(string):
	text.append(string)
	refresh()

#Signal handler triggered when the send button is pressed
func _on_Button_pressed():
	var string = $"GUI/LineEdit".text
	$"GUI/LineEdit".clear()
	var command = Command.new(string)
	if not command.exception == null:
		print_text("[color=red]"+string+"[/color]")
		print_text("[color=red]Exception: "+command.exception.get_description()+"[/color]")
		print_text("[color=red]Please enter a valid command...[/color]")
		return
	print_text(command.command)
	if command.is_local():
		callv(command.command, command.args)
	else:
		end_turn()
		rpc_id(player_id, "receive_command", string)

func _input(event):
	if event is InputEventKey and event.scancode == KEY_ENTER and Input.is_action_pressed("ui_accept"):
		_on_Button_pressed()

func end_turn():
	$"GUI/LineEdit".editable = false
	$"GUI/Button".disabled = true

#Stores the player's ip address
#PARAM address : String
remote func store_ip_address(address):
	player_ip_address = address
	text[text.size()-1] += " with ip address " + player_ip_address + "..."
	refresh()

remote func cli_turn():
	$"GUI/LineEdit".editable = true
	$"GUI/Button".disabled = false

remote func print_exception(exception):
	print_text(exception)

remote func sync_world(references):
	self.references = references

#Local commands

#Displays an insightful help message
#PARAM string : Arg(String)
func help(string):
	var command = Command.new(string.value)
	var formatted_args = ""
	for arg in command.args:
		formatted_args += str(arg.type_str)+", "
	formatted_args = formatted_args.substr(0, formatted_args.length()-2) #Remove last hyphen
	print_text("Command: "+command.command)
	print_text("\t*Arguments: "+("No argument" if formatted_args.empty() else formatted_args))
	print_text("\t*Description: "+command.description)

#Displays a list of all available commands
func list():
	print_text("List of all available commands:")
	for command in Command.commands:
		print_text("\t-"+command+":")
		var formatted_args = ""
		var args = []
		for i in range(Command.commands[command].size()-3):
			args.append(Argument.new(Command.commands[command][i]))
		for arg in args:
			formatted_args += str(arg.type_str)+", "
		formatted_args = formatted_args.substr(0, formatted_args.length()-2) #Remove last hyphen
		print_text("\t\t*Arguments: "+ ("No arguments" if formatted_args.length() == 0 else formatted_args))
		print_text("\t\t*Description: "+Command.commands[command][Command.commands[command].size()-2])
		print_text("")

#Displays the name of the host OS
func uname():
	var os_name = OS.get_name()
	print_text("Your OS is: " + os_name)
	print_text("")

#Display the list of monsters you summoned along with their ids
func id():
	print_text("List of monsters:")
	for id in references:
		print_text("\t-monster:")
		print_text("\t\tType :"+references[id]["type"])
		print_text("\t\tId :"+id)
		print_text("")