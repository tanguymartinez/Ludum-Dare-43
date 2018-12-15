extends Panel

const COLUMNS = 24
const ROWS = 3
var blocks = []
var height
var duration = 5000.0
var init_pos
var end_pos

func _init():
	height = rect_size.y
	init_pos = rect_position.y
	end_pos = -rect_position.y

func animate(text):
	#Hydrate blocks array
	##Init
	var start = OS.get_ticks_msec()
	blocks.clear()
	var array = []
	for i in range(ceil(float(text.length())/COLUMNS)): #Every line
		array.append(text.substr(i*COLUMNS, COLUMNS))
		if i%ROWS == 0 or (i == ceil(float(text.length())/COLUMNS)):
			blocks.append(array.duplicate())
			array.clear()
	
	text = blocks[0][0]
	while OS.get_ticks_msec() - start < duration:
		var elapsed = OS.get_ticks_msec() - start
		if elapsed <= duration/2.0:
			rect_position.y = init_pos+(rect_size.y/(duration/2.0)*elapsed)
		else:
			rect_position.y = end_pos-((duration/2.0)/rect_size.y*elapsed)
	rect_position.y = -rect_size.y