extends Spatial

export var is_branch = false
export var models = []

onready var cave_root = get_node("/root/Game/CaveRoot")
onready var seg_scale = cave_root.seg_scale
onready var dist_x = cave_root.dist_x

func _ready() -> void:
    var model = models[0].instance()
    add_child(model)
    model.scale = Vector3(1,1,1) * seg_scale
    model.get_child(0).get_child(0).set_surface_material(0, load("res://shaders/cave_mat.tres"))
    rotate_y(randf()*360)

    if is_branch:
        var new_start = preload("res://scenes/cave_start.tscn").instance()
        new_start.translation = Vector3(0, 0, -dist_x * seg_scale)
        new_start.rotation_degrees.y = 180
        new_start.get_child(0).scale = Vector3(1,1,1) * seg_scale
        add_child(new_start)
