extends Spatial

export var is_branch = false
export var models = []


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
        rotate_y(randf()*2 - 1)
    else:
        model.rotate_y(randf()*PI*2)

    model.add_decor()

    if is_branch:
        var new_start = load("res://scenes/cave_start.tscn").instance()
        new_start.translation = Vector3(0, 0, -dist_x * seg_scale)
        #new_start.rotation_degrees.y = 180
        new_start.get_child(0).scale = Vector3(1,1,1) * seg_scale
        #if randf() > 0.5:
        new_start.is_main = true
        get_parent().is_main = false
        add_child(new_start)

