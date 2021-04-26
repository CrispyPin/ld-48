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
    if randf() < 0.8:
        var s = load("res://scenes/shark.tscn").instance()
        s.transform.origin = global_transform.origin
        get_node("/root/Game").add_child(s)

func add_decor():
    var mdt = MeshDataTool.new()
    var mesh = get_mesh()
    mdt.create_from_surface(mesh, 0)

    #for vi in range(mdt.get_vertex_count()):
    for fi in range(mdt.get_face_count()):
        var vi = mdt.get_face_vertex(fi, 0)
        var vert = mdt.get_vertex(vi)
        var normal = mdt.get_face_normal(fi)
        if randf() > 0.8:
            var type = randi() % (len(decor)-1)
            if vert.length() > 2.3:
                type = 3
            var d = decor[type].instance()
            add_child(d)
            d.global_transform.origin = global_transform.xform(vert)
            d.scale = Vector3(1,1,1) / 5.0
            #d.rotation = Vector3(randf(), randf(), randf())*3.14
            #d.rotation = mdt.get_vertex_normal(vi)*3.14
            var up = Vector3(0,1,0)
            #d.transform = d.transform.looking_at(normal + d.translation, up)
            var pd = translation - vert
            #if pd.dot(normal)>0:
            #d.look_at(Vector3(),up)
            #d.look_at(d.translation + normal,up)
            d.look_at(translation + normal,up)
            d.rotate_object_local ( Vector3(1,0,0), -PI/2 )
            #else:
            #    d.look_at(-normal + d.translation, up)
