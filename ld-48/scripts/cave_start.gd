extends Spatial

onready var player = get_node("/root/Game/Player")
onready var boids = get_node("/root/Game/Boids")

var cave_root

var ypos;
var alive = true
export var is_main = false

var segments

var numBoids = 5

func _ready():
    cave_root = get_node("/root/Game/CaveRoot")
    segments = cave_root.segments

    ypos = global_transform.origin.y

func _process(_delta):
    if ypos > player.translation.y - cave_root.gen_depth and alive:
        ypos -= cave_root.dist_y * cave_root.seg_scale
        add_seg()

func add_seg():
#    var type;
#    if is_main:
#        type = randi() % 2
#    else:
#        type = randi() % 2 + 1
#
#    var seg = segments[type].instance()
    var seg = segments[1].instance()
    seg.translation = Vector3(0, ypos - global_transform.origin.y, 0)

    add_child(seg)

#
#    if type == 2:
#        alive = false


