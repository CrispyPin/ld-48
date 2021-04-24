extends Spatial

onready var player = get_node("/root/Game/Player")
var cave_root

var ypos;
var alive = true

var segments


func _ready():
	cave_root = get_node("/root/Game/CaveRoot")
	segments = cave_root.segments

	ypos = transform.origin.y

func _process(_delta):
	if ypos - player.transform.origin.y > cave_root.gen_depth and alive:
		ypos -= cave_root.dist_y
		add_seg()

func add_seg():
	var type = int(rand_range(0, 3))
	var i = int(rand_range(0, len(segments[type])))
	var seg = segments[type][i].instance()
	seg.transform.origin = transform.origin + Vector3(0, ypos, 0)
	seg.get_child(0).get_child(0).set_surface_material(0, load("res://shaders/cave_mat.tres"))
	add_child(seg)
	if type == 2:
		alive = false


