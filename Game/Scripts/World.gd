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

#Monsters related
var monsters_map = {}

#Map related
var files = []
var tiles_scn = [] #TO-DO implement getter to remove duplicate duplicate
var map = [] #map of actual node instances
var tile_hovered = Vector2(0, 0)
var direction_hints = [] #tiles showing where one can move
var direction_offsets = [Vector2(-1, 0), Vector2(0, -1), Vector2(1, 0), Vector2(0, 1)] #offset from one's position, multiplicable
#
##Referencing purposes
#var ids = []

#Player
var player_instance

#HUD logic

# Called when the node enters the scene tree for the first time.
func _ready():
	player_instance = player.instance()
	player_instance.find_node("Area2D").connect("player_clicked", self, "_on_Player_clicked")
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
	toggle_highlight_tile(Vector2(0,0))

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
	if event is InputEventMouseMotion and not hud_visible():
		tile_hovered(event.position)

#Converts pixels position into map index
#PARAM pos : Vector2
#RETURNS Vector2
func get_map_index(pos):
	return Vector2(floor(pos.x/PIXELS), floor(pos.y/PIXELS))

#Converts pixels direction into map dir
#PARAM dir : Vector2
func get_map_dir(dir):
	return Vector2(dir.x/PIXELS, dir.y/PIXELS)

#Spawns <node> at the specified <pos> map location
#PARAM pos: Vector2
func spawn(node, pos):
	for node_tmp in map[pos.y][pos.x].get_children():
		if Groups.blocking(node_tmp):
			print("Can't spawn on colliding tile...")
			return
	map[pos.y][pos.x].add_child(node)

#Moves the player of <dir> tiles
#PARAM dir : Vector2
func move_player(dir):
	if not direction_hints.empty():
		var player_pos = player_instance.get_node("../").position
		var map_index = get_map_index(player_pos)
		var map_dir = get_map_dir(dir)
		player_instance.get_node("../").remove_child(player_instance)
		map[map_index.y+map_dir.y][map_index.x+map_dir.x].add_child(player_instance)
		remove_direction_hints()

func end_turn():
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
		if tile_hovered != indexes:
			toggle_highlight_tile(tile_hovered)
			tile_hovered = indexes
			toggle_highlight_tile(tile_hovered)

#Toggles the selection tile at the specified map position
#PARAM pos : Vector2
func toggle_highlight_tile(pos):
	if in_bounds(pos, map[0].size(), map.size()):
		if map[pos.y][pos.x].has_node(overlay.instance().get_name()):
			for node in map[pos.y][pos.x].get_children():
				if node.get_name() == overlay.instance().get_name():
					map[pos.y][pos.x].remove_child(node)
					node.queue_free()
		else:
			map[pos.y][pos.x].add_child(overlay.instance())

#Toggles HUD
func toggle_hud():
	player_instance.find_node("Control").visible = not hud_visible()

#Check whether HUD is visible
#RETURN bool
func hud_visible():
	return true if player_instance.find_node("Control").visible else false

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

#Signal handler triggered when the attack button clicked
func _on_Attack_clicked():
	toggle_hud()
#	if direction_hints.empty():
#		generate_direction_hints(2)
#	else:
#		remove_direction_hints()

#Signal handler triggered when the teleport button is clicked
func _on_Teleport_clicked():
	toggle_hud()
#	if direction_hints.empty():
#		generate_direction_hints(2)
#	else:
#		remove_direction_hints()

#Signal handler triggered when a hint is clicked
func _on_Hint_clicked(pos):
	move_player(pos)

#Specify when it is the player's turn, casting CLI events onto the map first
#PARAM command : Command
remote func player_turn(string):
	var command = Command.new(string)
	var exception = callv(command.command, command.args)
	if not exception == null:
		$"..".exception(exception.get_exception())


#Commands

#Spawns an enemy at the specified <x,y> position
#PARAM x : Arg(Int)
#PARAM y : Arg(Int)
#PARAM type : Arg(String)
func monster(x, y, type):
	var pos = Vector2(x.value, y.value)
	var monster = get("monster_"+type).instance()
	spawn(monster, pos)
func monster_check(pos, type):
	if not in_bounds(pos, GRID_WIDTH, GRID_HEIGHT):
		return Exception.new(Enums.EXCEPTIONS.OUT_OF_RANGE)
	if not type in Enemy.MONSTERS:
		return Exception.new(Enums.EXCEPTIONS.UNKNOWN_TYPE)
	return null #Default