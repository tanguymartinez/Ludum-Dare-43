extends Panel

const COLUMNS = 24
const ROWS = 3
var anims = []
var anims_index = 0
var blocks = []
var blocks_index = 0
var height
var duration = 3000.0
var still_time = 2000.0
var init_pos
var end_pos
var play = false
var start

func _ready():
	height = rect_size.y
	init_pos = rect_position.y
	end_pos = 0

func _process(delta):
	if play:
		animate()

func initialize(string):
	##Init
	blocks.clear()
	var array = []
	for i in range(ceil(float(string.length())/COLUMNS)): #Every line
		array.append(string.substr(i*COLUMNS, COLUMNS))
		if i%ROWS == 0 or (i == ceil(float(string.length())/COLUMNS)):
			blocks.append(array.duplicate())
			array.clear()
	anims.append(blocks.duplicate())
	update_display(0,0)

func start(string):
	if not start:
		start = OS.get_ticks_msec()
		initialize(string)
		play = true
	else:
		initialize(string)

func animate():
	if OS.get_ticks_msec() - start < duration:
		var elapsed = OS.get_ticks_msec() - start
		if elapsed <= (duration-still_time)/2.0:
			rect_position.y = init_pos+(rect_size.y/((duration-still_time)/2.0)*elapsed)
		elif elapsed >= (duration+still_time)/2.0:
			rect_position.y = init_pos+(rect_size.y/((duration-still_time)/2.0)*(duration-elapsed))
	else:
		next()

func next():
	if blocks_index == blocks.size()-1:
		if anims_index == anims.size()-1:
			anims.clear()
			anims_index = 0
			play = false
		else:
			anims_index += 1
		blocks_index = 0
	else:
		blocks_index += 1
	if play:
		update_display(anims_index, blocks_index)
		start = OS.get_ticks_msec()

func update_display(a_index, b_index):
	var string = ""
	for line in anims[a_index][b_index]:
		string += line + "\n"
	get_node("Label").text = string