extends Node2D

#Constants
var GRID_WIDTH = Variables.GRID_WIDTH
var GRID_HEIGHT = Variables.GRID_HEIGHT
var PIXELS = Variables.PIXELS
const PATH_TO_GROUND = "res://res/Img/Tiles/Ground"

#Exports
export(PackedScene) var default_tile_scene
export(PackedScene) var overlay
export(PackedScene) var player
export(PackedScene) var hint
export(PackedScene) var monster_red
export(PackedScene) var monster_blue
export(PackedScene) var monster_yellow
export(PackedScene) var monster_green
export(PackedScene) var flag
export(PackedScene) var pavilion

#Monsters related
var references = {
	#id : {"node" : <node>, ...properties]
}

#Map related
var files = []
var tiles_scn = [] #TO-DO implement getter to remove duplicate duplicate
var map = [] #map of actual node instances
var direction_hints = [] #tiles showing where one can move
var direction_offsets = [Vector2(-1, 0), Vector2(0, -1), Vector2(1, 0), Vector2(0, 1)] #offset from one's position, multiplicable

#Player
var player_instance
var action

#HUD logic
var overlay_instance

#Notifications purpose
var lines = []
var lines_index = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	action = Enums.ACTIONS.NONE
	player_instance = player.instance()
	player_instance.connect("player_clicked", self, "_on_Player_clicked")
	player_instance.find_node("GridContainer").connect("move_clicked", self, "_on_Move_clicked")
	player_instance.find_node("GridContainer").connect("attack_clicked", self, "_on_Attack_clicked")
	player_instance.find_node("GridContainer").connect("teleport_clicked", self, "_on_Teleport_clicked")
	
	files = list_files_in_directory(PATH_TO_GROUND)
	files.sort()
	for file in files:
		var instance = default_tile_scene.instance()
		var image = Image.new()
		image.load(PATH_TO_GROUND+"/"+str(file))
		var texture = ImageTexture.new()
		texture.create_from_image(image, 1)
		instance.get_node("Sprite").texture = texture
		instance.get_node("Sprite").z_index = -1
		tiles_scn.append(instance)
	init_map()
	overlay_instance = overlay.instance()
	map[0][0].add_child(overlay_instance)

#Generate map
func init_map():
	for i in range(GRID_HEIGHT):
		map.append([])
		for j in range(GRID_WIDTH):
			map[i].append("")
			if (i+j) == 0:
				map[i][j] = tiles_scn[5].duplicate()
			elif j == GRID_WIDTH-1 and i == GRID_HEIGHT-1:
				map[i][j] = tiles_scn[1].duplicate()
			elif j == GRID_WIDTH-1 and i == 0:
				map[i][j] = tiles_scn[6].duplicate()
			elif j == 0 && i == GRID_HEIGHT-1:
				map[i][j] = tiles_scn[0].duplicate()
			elif i == 0:
				map[i][j] = tiles_scn[7].duplicate()
			elif i == GRID_HEIGHT-1:
				map[i][j] = tiles_scn[2].duplicate()
			elif j == GRID_WIDTH-1:
				map[i][j] = tiles_scn[4].duplicate()
			elif j == 0:
				map[i][j] = tiles_scn[3].duplicate()
			else:
				map[i][j] = tiles_scn[8].duplicate()
	for i in range(map.size()):
		for j in range(map[0].size()):
			map[i][j].position = Vector2(j*100, i*100)
			map[i][j].z_index = -1
			self.get_node("Tiles").add_child(map[i][j])

#List files in a directory
#PARAM path : String
#RETURNS array
func list_files_in_directory(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin(true, true)
	
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif file.ends_with("png"):
			files.append(file)
	
	dir.list_dir_end()
	
	return files

#Triggered when an event is actionned
func _input(event):
	# Mouse in viewport coordinates
	if event is InputEventMouseButton and Input.is_action_pressed("ui_click"):
		if not player_instance.is_inside_tree():
			spawn(player_instance, get_map_index(event.position))
			end_turn()
	if event is InputEventMouseMotion and not hud_visible():
		tile_hovered(event.position)

#Converts pixels position into map index
#PARAM pos : Vector2
#RETURNS Vector2
func get_map_index(pos):
	return Vector2(floor(pos.x/PIXELS), floor(pos.y/PIXELS))

#Converts pixels direction into map dir
#PARAM dir : Vector2
#RETURN Vector2
func get_map_dir(dir):
	return Vector2(dir.x/PIXELS, dir.y/PIXELS)

#Determines if the specified tile contains a collider
func collides(pos):
	if not in_bounds(pos, GRID_HEIGHT, GRID_WIDTH):
		return false
	for node_tmp in map[pos.y][pos.x].get_children():
		if Groups.blocking(node_tmp):
			print("Can't spawn on colliding tile...")
			return true
	return false

#Spawns <node> at the specified <pos> map location
#PARAM pos: Vector2
#RETURN bool
func spawn(node, pos):
	if collides(pos):
		return false
		print("Can't spawn on colliding tile!")
	map[pos.y][pos.x].add_child(node)
	if node is Entity:
		node.connect("attack", self, "_on_Entity_attack")
	if node is Enemy:
		node.connect("enemy_clicked", self, "_on_Enemy_clicked")
		references_insert(node, Enemy.TYPES.keys()[(node as Enemy).type])
	return true

#Moves the player of <dir> tiles
#PARAM dir : Vector2
func move_player(dir):
	if not direction_hints.empty():
		var player_pos = player_instance.get_node("../").position
		var map_index = get_map_index(player_pos)
		var map_dir = get_map_dir(dir)
		player_instance.get_node("../").remove_child(player_instance)
		map[map_index.y+map_dir.y][map_index.x+map_dir.x].add_child(player_instance)

func end_turn():
	action = Enums.ACTIONS.NONE
	$"..".end_turn()

#Hide and remove direction hints
func remove_direction_hints():
	for i in range(0, player_instance.get_node("Hints").get_child_count()):
		player_instance.get_node("Hints").get_child(i).queue_free()
	direction_hints.clear()

#Generate and display direction hints of distance <length>
#PARAM length : int
func generate_direction_hints(length):
	var pos = get_map_index(player_instance.get_node("../").position)
	for offset in direction_offsets:
		for index in range(1, length+1):
			var blocking = false
			if in_bounds(Vector2(pos.x + offset.x * index, pos.y + offset.y * index), map[0].size(), map.size()):
				for node in map[pos.y + offset.y * index][pos.x + offset.x * index].get_children():
					if Groups.blocking(node):
						blocking = true
				if not blocking:
					var hint_instance = hint.instance()
					hint_instance.find_node("Area2D").connect("hint_clicked", self, "_on_Hint_clicked")
					hint_instance.z_index = 10
					hint_instance.position = Vector2(offset.x * index * PIXELS, offset.y * index * PIXELS)
					direction_hints.append(hint_instance)
					player_instance.get_node("Hints").add_child(hint_instance)
				else:
					break;


#Updates position of the selection tile
#PARAM pos : Vector2
func tile_hovered(pos):
	if in_bounds(pos, OS.get_screen_size().x, OS.get_screen_size().y):
		var indexes = get_map_index(pos)
		if get_map_index(overlay_instance.get_node("../").position) != indexes:
			overlay_instance.get_node("../").remove_child(overlay_instance)
			map[indexes.y][indexes.x].add_child(overlay_instance)

#Toggles HUD
func toggle_hud():
	player_instance.find_node("Control").visible = not hud_visible()

#Check whether HUD is visible
#RETURN bool
func hud_visible():
	return true if player_instance.find_node("Control").visible else false

func notify(text):
	pass

#Checks whether the position supplied is in the grid of width <width> and height <height>
#PARAM pos : Vector2
#PARAM width : int
#PARAM height : int
#RETURN bool
func in_bounds(pos, width, height):
	if 0 <= pos.x and pos.x < width and 0 <= pos.y and pos.y < height:
		return true
	return false

#Signal handler triggered when the player is clicked
func _on_Player_clicked():
	toggle_hud()
	if not direction_hints.empty():
		remove_direction_hints()

#Signal handler triggered when the move button is clicked
func _on_Move_clicked():
	toggle_hud()
	if direction_hints.empty():
		generate_direction_hints(2)
		action = Enums.ACTIONS.MOVE

#Signal handler triggered when the attack button clicked
func _on_Attack_clicked():
	toggle_hud()
	if overlay_instance.texture != overlay_instance.attacking:
		overlay_instance.texture = overlay_instance.attacking
		player_instance.state = Enums.STATUS.ATTACKING
	else:
		overlay_instance.texture = overlay_instance.selecting
		player_instance.state = Enums.STATUS.IDLE

#Signal handler triggered when the teleport button is clicked
func _on_Teleport_clicked():
	toggle_hud()

#Signal handler triggered when a hint is clicked
func _on_Hint_clicked(pos):
	match action:
		Enums.ACTIONS.MOVE:
			move_player(pos)
		Enums.ACTIONS.PAVILION:
			var pavilion_instance = overlay_instance.get_children()[0]
			overlay_instance.remove_child(pavilion_instance)
			pavilion_instance.modulate = Color(1,1,1,1)
			var end_pos = get_map_index(player_instance.get_node("../").position)+get_map_index(pos)
			spawn(pavilion_instance, end_pos)
		_:
			print("No action selected!")
	remove_direction_hints()
	action = Enums.ACTIONS.NONE
	sync_world()
	end_turn()

#Signal handler triggered when an enemy is clicked
func _on_Enemy_clicked(pos, id):
	if player_instance.state == Enums.STATUS.ATTACKING:
		player_instance.attack(id)

func _on_Entity_attack(sender, receiver, damage):
	if sender == player_instance.id:
		print("Player attacked #"+str(receiver)+" of type "+references[receiver]["type"]+", causing it "+str(damage)+" HP loss")
	else:
		print("Entity #"+str(sender)+" attacked #"+str(receiver)+" of type "+references[receiver]["type"]+", causing it "+damage+" HP loss")
	if references[receiver]["node"].attacked(damage):
		var pos = references[receiver]["node"].get_node("../").position
		references[receiver]["node"].get_node("../").remove_child(references[receiver]["node"])
		spawn(flag.instance(), get_map_index(pos))
		references[receiver]["status"] = Enums.STATUS.DEAD
		player_instance.inc_conquered()
		overlay_instance.texture = overlay_instance.selecting #Switch back to selecting
		if player_instance.pavilion():
			action = Enums.ACTIONS.PAVILION
			select_pavilion()
	else:
		sync_world()
		end_turn()

func select_pavilion():
	var pavilion_instance = pavilion.instance()
	pavilion_instance.modulate = Color(1,1,1,0.5)
	overlay_instance.add_child(pavilion_instance)
	generate_direction_hints(1)

#Specify when it is the player's turn, casting CLI events onto the map first
#PARAM command : Command
func player_turn(string):
	var command = Command.new(string)
	var exception = call("exec_command", command)
	if not exception == null:
		$"..".exception(exception.get_description())
		end_turn()
	else:
		var formatted_args = ""
		for arg in command.args:
			formatted_args += str(arg) + " "
		formatted_args = formatted_args.substr(0, formatted_args.length()-1) 
		$"../Control".start("The researcher has issued a new command: ")
		$"../Control".start(command.command+" "+formatted_args)
		get_tree().paused = false

#Insert a new entry into references
func references_insert(node, type):
	node.id = references.size()
	references[references.size()] = {
		"node" : node,
		"type" : type,
		"status" : Enums.STATUS.IDLE,
		"position" : get_map_index(node.position)
	}

func sync_world():
	$"..".sync_world()

#Commands

#Execute standard command, you MUST call the checking function "<command_name>_check"
#Param command : Command
func exec_command(command):
	match callv(command.command+"_check", command.args):
		null:
			callv(command.command, command.args)
			sync_world()
			return null
		var exception:
			return exception

#Spawns an enemy at the specified <x,y> position
#PARAM x : Arg(Int)
#PARAM y : Arg(Int)
#PARAM type : Arg(String)
func monster(x, y, type):
	var pos = Vector2(x, y)
	var monster = get("monster_"+type).instance()
	spawn(monster, pos)
func monster_check(x, y, type):
	if not in_bounds(Vector2(x, y), GRID_WIDTH, GRID_HEIGHT):
		return Exception.new(Enums.EXCEPTIONS.OUT_OF_RANGE)
	if not type in Enemy.MONSTERS:
		return Exception.new(Enums.EXCEPTIONS.UNKNOWN_TYPE)
	return null #Default

#Moves entity <id> from specified <offset_x, offset_y> position
#PARAM id : Arg(id)
#PARAM offset_x : Arg(Int)
#PARAM offset_y : Arg(Int)
func move(id, offset_x, offset_y):
	var node = references[id]["node"]
	var pos = get_map_index(node.get_node("../").position)
	node.get_node("../").remove_child(node)
	map[pos.y+offset_y][pos.x+offset_x].add_child(node)
	return null
func move_check(id, offset_x, offset_y):
	if references[id]["status"] == Enums.STATUS.DEAD:
		return Exception.new(Enums.EXCEPTIONS.DEAD_ENTITY)
	if not in_bounds(get_map_index(references[id]["node"].get_node("../").position)+Vector2(offset_x, offset_y), GRID_WIDTH, GRID_HEIGHT):
		return Exception.new(Enums.EXCEPTIONS.OUT_OF_RANGE)
	if collides(get_map_index(references[id]["node"].get_node("../").position)+Vector2(offset_x, offset_y)):
		return Exception.new(Enums.EXCEPTIONS.TILE_COLLIDES)
	if not references.has(id):
		return Exception.new(Enums.EXCEPTIONS.UNKNOWN_REFERENCE)
	return null #Default