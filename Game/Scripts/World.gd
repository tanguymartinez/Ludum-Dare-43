extends Node2D

const GRID_WIDTH = 15
const GRID_HEIGHT = 10
const PIXELS = 100
const PATH_TO_GROUND = "res://res/Img/Tiles/Ground"
var files = []
export(PackedScene) var default_tile_scene
export(PackedScene) var overlay
export(PackedScene) var player
export(PackedScene) var hint
var player_instance
var tiles_scn = [] #TO-DO implement getter to remove duplicate duplicate
var map = [] #map of actual node instances
var tile_hovered = Vector2(0, 0)
var direction_hints = []

# Called when the node enters the scene tree for the first time.
func _ready():
	player_instance = player.instance()
	
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

func _input(event):
#   # Mouse in viewport coordinates
	if event is InputEventMouseButton and Input.is_action_pressed("ui_click"):
		spawn_player(event.position)
	if event is InputEventMouseMotion:
		tile_hovered(event.position)

func get_map_index(pos):
	return Vector2(floor(pos.x/PIXELS), floor(pos.y/PIXELS))

func spawn_player(pos):
	var indexes = get_map_index(pos)
	player_instance.find_node("Area2D").connect("player_clicked", self, "_on_Player_clicked")
	map[indexes.y][indexes.x].add_child(player_instance)

func tile_hovered(pos):
	if in_bounds(pos, OS.get_screen_size().x, OS.get_screen_size().y):
		var indexes = get_map_index(pos)
		if tile_hovered != indexes:
			toggle_highlight_tile(tile_hovered)
			tile_hovered = indexes
			toggle_highlight_tile(tile_hovered)
		
func toggle_highlight_tile(pos):
	if in_bounds(pos, map[0].size(), map.size()):
		if map[pos.y][pos.x].has_node(overlay.instance().get_name()):
			for node in map[pos.y][pos.x].get_children():
				if node.get_name() == overlay.instance().get_name():
					map[pos.y][pos.x].remove_child(node)
					node.queue_free()
		else:
			map[pos.y][pos.x].add_child(overlay.instance())
	
func in_bounds(pos, width, height):
	if 0 <= pos.x and pos.x <= width and 0 <= pos.y and pos.y <= height:
		return true
	return false

func _on_Player_clicked():
	print("clicked")
	generate_direction_hints()
	
func empty(nodes):
	for child in nodes:
		if not Groups.empty(child):
			return false
	return true
	
func generate_direction_hints():
	var pos = get_map_index(player_instance.get_node("../").position)
	var top
	var right
	var bottom
	var left
	if empty(map[pos.y][pos.x].get_children()):
		pass