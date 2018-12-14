class_name Enemy
extends "Entity.gd"

#Signal emitted when an enemy is clicked
#PARAM pos : Vector2
#PARAM id: int
signal enemy_clicked(pos, id)

enum TYPES{RED, BLUE, GREEN,YELLOW}
const MONSTERS = {"red" : "Drops weapons when killed", "blue" : "Boosts the player's actions when killed", "green" : "Drops resources when killed", "yellow" : "Drops gold when kiled"}
var type setget set_type,get_type

func _ready():
	self.add_to_group(str(Enums.COLLIDER.ENEMY))

func set_type(monster_type):
	if monster_type in TYPES.values():
		type = monster_type

func get_type():
	return type

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and Input.is_action_pressed("ui_click"):
		emit_signal("enemy_clicked", self.get_node("../").position, get_id())
