extends Node2D

const GRID_WIDTH = 15
const GRID_HEIGHT = 10
const PIXELS = 100
var files = []
export(PackedScene) var default_tile_scene
var tiles_scn = []
var map = []

# Called when the node enters the scene tree for the first time.
func _ready():
	files = list_files_in_directory("res://res/Img/Tiles/")
	print(files)
	for file in files:
		var instance = default_tile_scene.instance()
		var image = Image.new()
		image.load("res://res/Img/Tiles/"+str(file))
		var texture = ImageTexture.new()
		texture.create_from_image(image, 1)
		instance.texture = texture
		tiles_scn.append(instance)

func init_map():
	for i in range(GRID_WIDTH):
		map[i] = []
		for j in range(GRID_HEIGHT):
			if (i+j) == 0:
				map[i][j] = tiles_scn[5]
			elif i == GRID_WIDTH-1 and j == GRID_HEIGHT-1:
				map[i][j] = tiles_scn[1]
			elif i == GRID_WIDTH-1 and j == 0:
				map[i][j] = tiles_scn[6]
			elif i == 0 && j == GRID_HEIGHT-1:
				map[i][j] = tiles_scn[0]
			elif j == 0:
				map[i][j] = tiles_scn[7]
			elif j == GRID_HEIGHT-1:
				map[i][j] = tiles_scn[2]
			elif i == GRID_WIDTH-1:
				map[i][j] = tiles_scn[4]
			elif i == 0:
				map[i][j] = tiles_scn[3]
			else:
				map[i][j] = tiles_scn[8]
	for i in range(map.size()-1):
		for j in range(map[0].size()):
			map[i][j].position = Vector2(i*100, j*100)
			self.add_child(map[i][j])


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


