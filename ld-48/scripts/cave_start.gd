extends Spatial

onready var player = get_node("/root/Game/Player")
var cave_root

var ypos;
var alive = true

var segments


func _ready():
    cave_root = get_node("/root/Game/CaveRoot")
    segments = cave_root.segments

    ypos = global_transform.origin.y

func _process(_delta):
    if ypos > player.translation.y - cave_root.gen_depth and alive:
        ypos -= cave_root.dist_y * cave_root.seg_scale
        add_seg()

func add_seg():
    var type = int(rand_range(0, 3))
    var seg = segments[type].instance()
    seg.translation = Vector3(0, ypos - global_transform.origin.y, 0)

    add_child(seg)
    if type == 2:
        alive = false


