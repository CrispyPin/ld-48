extends MeshInstance

export var self_activate = false

var decor = [preload("res://models/seagrass/seagrass-1.tscn"),
preload("res://models/seagrass/seagrass-2.tscn"),
preload("res://models/seagrass/seagrass-3.tscn"),
preload("res://models/seagrass/flower-1.tscn")]

onready var cave_root = get_node("/root/Game/CaveRoot")
onready var seg_scale = cave_root.seg_scale

func _ready() -> void:
    if self_activate:
        add_decor()

func add_decor():
    var mdt = MeshDataTool.new()
    var mesh = get_mesh()
    mdt.create_from_surface(mesh, 0)

    for vi in range(mdt.get_vertex_count()):
        var vert = mdt.get_vertex(vi)
        if randf() > 0.8:
            var type = randi() % (len(decor)-1)
            if vert.length() > 2.3:
                type = 3
            var d = decor[type].instance()
            add_child(d)
            d.global_transform.origin = global_transform.xform(vert)
            d.scale = Vector3(1,1,1) / 6.0
            d.rotation = Vector3(randf(), randf(), randf())*PI*2
