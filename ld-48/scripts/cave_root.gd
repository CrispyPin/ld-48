extends Spatial

export var gen_depth = 256#how far ahead to generate

export var seg_scale = 32
export var dist_y = 2.5
export var dist_x = 4

export var segments = [preload("res://scenes/cave_segments/seg_branch.tscn"),
                        preload("res://scenes/cave_segments/seg_straight.tscn"),
                        preload("res://scenes/cave_segments/seg_end.tscn")]

onready var player = get_node("/root/Game/Player")

func _ready() -> void:
    $cave_top.scale = Vector3(1,1,1)*seg_scale
