extends MeshInstance

export var self_activate = false

var decor = [preload("res://models/seagrass/seagrass-1.tscn"),
preload("res://models/seagrass/seagrass-2.tscn"),
preload("res://models/seagrass/seagrass-3.tscn"),
preload("res://models/seagrass/flower-1.tscn")]

onready var cave_root = get_node("/root/Game/CaveRoot")
onready var seg_scale = cave_root.seg_scale

func _ready() -> void:
    add_decor()
    if randf() < 0.8:
        var s = load("res://scenes/shark.tscn").instance()
        s.transform.origin = global_transform.origin
        get_node("/root/Game").add_child(s)

func add_decor():
    var mdt = MeshDataTool.new()
    var mesh = get_mesh()
    mdt.create_from_surface(mesh, 0)

    for fi in range(mdt.get_face_count()):
        var vi = mdt.get_face_vertex(fi, 0)
        var vert = mdt.get_vertex(vi)
        var normal = mdt.get_face_normal(fi)
        if randf() > 0.8:
            _add_decor_item(vert, normal)


func _add_decor_item(vert, normal):
    var type = randi() % (len(decor))
#    if vert.length() > 2.3:
#        type = 3
    var d = decor[type].instance()
    add_child(d)
    d.global_transform.origin = global_transform.xform(vert)
    d.scale = Vector3(1,1,1) / 5.0

    var normal2 = Vector2(normal.x,normal.z)
    d.rotate_z(normal2.angle() - PI/2)
    d.rotate_x(atan(-normal.y))

