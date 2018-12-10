class_name Argument

var type setget ,get_type
var type_str setget ,get_type_string

const types = [
	"TYPE_NIL",
	"TYPE_BOOL",
	"TYPE_INT",
	"TYPE_REAL",
	"TYPE_STRING",
	"TYPE_VECTOR2",
	"TYPE_RECT2",
	"TYPE_VECTOR3",
	"TYPE_TRANSFORM2D",
	"TYPE_PLANE",
	"TYPE_QUAT",
	"TYPE_AABB",
	"TYPE_BASIS",
	"TYPE_TRANSFORM",
	"TYPE_COLOR",
	"TYPE_NODE_PATH",
	"TYPE_RID",
	"TYPE_OBJECT",
	"TYPE_DICTIONARY",
	"TYPE_ARRAY",
	"TYPE_RAW_ARRAY",
	"TYPE_INT_ARRAY",
	"TYPE_REAL_ARRAY",
	"TYPE_STRING_ARRAY",
	"TYPE_VECTOR2_ARRAY",
	"TYPE_VECTOR3_ARRAY",
	"TYPE_COLOR_ARRAY",
	"TYPE_MAX"
]

func _init(type):
	if 0 <= type and type <= TYPE_MAX:
		self.type = type
		self.type_str = types[type]
	else:
		print("Failed building argument, type mismatch...")

func get_type():
	return type

func get_type_string():
	return type_str