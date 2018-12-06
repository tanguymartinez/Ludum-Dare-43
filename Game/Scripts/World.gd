extends Node2D

#Constants
const GRID_WIDTH = 15
const GRID_HEIGHT = 10
const PIXELS = 100
const PATH_TO_GROUND = "res://res/Img/Tiles/Ground"
var files = []

#Exports
export(PackedScene) var default_tile_scene
export(PackedScene) var overlay
export(PackedScene) var player
export(PackedScene) var hint

#map related
var tiles_scn = [] #TO-DO implement getter to remove duplicate duplicate
var map = [] #map of actual node instances
var tile_hovered = Vector2(0, 0)
var direction_hints = [] #tiles showing where one can move
var direction_offsets = [Vector2(-1, 0), Vector2(0, -1), Vector2(1, 0), Vector2(0, 1)] #offset from one's position, multiplicable

#player
var player_instance

# Called when the node enters the scene tree for the first time.
func _ready():
	player_instance = player.instance()
	player_instance.find_node("Area2D").connect("player_clicked", self, "_on_Player_clicked")
	
	files = list_files_in_directory(PATH_TO_GROUND)
	files.sort()
	for file in files:
		var instance = default_tile_scene.instance()
		var image = Image.new()
		image.load(PATH_TO_GROUND+"/"+str(file))
		var texture = ImageTexture.new()
		texture.create_from_image(image, 1)
		instance.get_node("Sand").texture = texture
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
		spawn_player(event.position)
	if event is InputEventMouseMotion:
		tile_hovered(event.position)

#Converts pixels position into map index
#PARAM pos : Vector2
#RETURNS Vector2
func get_map_index(pos):
	return Vector2(floor(pos.x/PIXELS), floor(pos.y/PIXELS))

#Spawns player at specified pixels location
#PARAM pos: Vector2
func spawn_player(pos):
	var indexes = get_map_index(pos)
	map[indexes.y][indexes.x].add_child(player_instance)

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

#Checks whether the position supplied is in the grid of width <width> and height <height>
#PARAM pos : Vector2
#PARAM width : int
#PARAM height : int
func in_bounds(pos, width, height):
	if 0 <= pos.x and pos.x < width and 0 <= pos.y and pos.y < height:
		return true
	return false

#Signal handler triggered when the player is clicked
func _on_Player_clicked():
	if direction_hints.empty():
		generate_direction_hints(2)
	else:
		direction_hints.clear()
		remove_direction_hints()

#Hide and remove direction hints
func remove_direction_hints():
	for i in range(0, player_instance.get_node("Hints").get_child_count()):
		player_instance.get_node("Hints").get_child(i).queue_free()

#Generate and display direction hints of distance <length>
#PARAM length : int
func generate_direction_hints(length):
	var pos = get_map_index(player_instance.get_node("../").position)
	for index in range(1, length+1):
		for offset in direction_offsets:
			var blocking = false
			if in_bounds(Vector2(pos.x + offset.x * index, pos.y + offset.y * index), map[0].size(), map.size()):
				for node in map[pos.y + offset.y * index][pos.x + offset.x * index].get_children():
					if Groups.blocking(node):
						blocking = true	
				if not blocking:
					var hint_instance = hint.instance()
					hint_instance.z_index = 10
					print(Vector2(offset.y * index * PIXELS, offset.x * index * PIXELS))
					hint_instance.position = Vector2(offset.x * index * PIXELS, offset.y * index * PIXELS)
					direction_hints.append(hint_instance)
					player_instance.get_node("Hints").add_child(hint_instance)

