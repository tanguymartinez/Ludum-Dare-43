class_name Player
extends "Entity.gd"

signal player_clicked()

const pavilion_treshold = 3
var conquered setget set_conquered,get_conquered

func _ready():
	add_to_group(str(Enums.COLLIDER.ALLY))
	id = -1
	conquered = 0

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and Input.is_action_pressed("ui_click"):
		emit_signal("player_clicked")

func set_conquered(num):
	conquered = num

func get_conquered():
	return conquered

func inc_conquered():
	conquered += 1

func pavilion():
	return true if (conquered%pavilion_treshold == 0 and conquered != 0) else false

