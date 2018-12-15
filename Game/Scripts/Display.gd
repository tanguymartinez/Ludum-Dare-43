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
var full_text

func _ready():
	height = rect_size.y
	init_pos = rect_position.y
	end_pos = 0

func _process(delta):
	if play:
		animate()

func initialize(string):
	##Init
	full_text = string
	var start = OS.get_ticks_msec()
	blocks.clear()
	var array = []
	for i in range(ceil(float(full_text.length())/COLUMNS)): #Every line
		array.append(full_text.substr(i*COLUMNS, COLUMNS))
		if i%ROWS == 0 or (i == ceil(float(full_text.length())/COLUMNS)):
			blocks.append(array.duplicate())
			array.clear()
	anims.append(blocks.duplicate())

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
		else:
			anims_index += 1
		blocks_index = 0
	else:
		blocks_index += 1
	start = OS.get_ticks_msec()