extends Spatial

export var is_branch = false
export var models = []
var decor = [preload("res://models/seagrass/seagrass-1.tscn"),
preload("res://models/seagrass/seagrass-2.tscn"),
preload("res://models/seagrass/seagrass-3.tscn")]

onready var cave_root = get_node("/root/Game/CaveRoot")
onready var seg_scale = cave_root.seg_scale
onready var dist_x = cave_root.dist_x

func _ready() -> void:
    $CollisionShape.scale = Vector3(1,1,1) * seg_scale
    var model = models[0].instance()
    add_child(model)
    model.scale = Vector3(1,1,1) * seg_scale

    model.set_surface_material(0, load("res://shaders/cave_mat.tres"))
    if is_branch:
        rotate_y(randf() * 60 + 150)
    else:
        model.rotate_y(randf()*360)

    add_decor(model)

    if is_branch:
        var new_start = load("res://scenes/cave_start.tscn").instance()
        new_start.translation = Vector3(0, 0, -dist_x * seg_scale)
        #new_start.rotation_degrees.y = 180
        new_start.get_child(0).scale = Vector3(1,1,1) * seg_scale
        if randf() > 0.5:
            new_start.is_main = true
            get_parent().is_main = false
        add_child(new_start)

func add_decor(model):
    var mdt = MeshDataTool.new()
    var mesh = model.get_mesh()
    mdt.create_from_surface(mesh, 0)
    for vi in range(mdt.get_vertex_count()):
        var vert = mdt.get_vertex(vi)
        if randf() > 0.9:
            var type = randi() % len(decor)
            var d = decor[type].instance()
            add_child(d)
            d.global_transform.origin = model.global_transform.xform(vert)
            d.scale = Vector3(5,5,5)
            d.rotation = Vector3(randf(), randf(), randf())*3.14
