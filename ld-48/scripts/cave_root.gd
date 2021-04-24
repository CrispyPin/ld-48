extends Spatial

export var gen_depth = 10#how far ahead to generate

export var seg_scale = 10
export var dist_y = 2.5
export var dist_x = 4

export var segments = [preload("res://scenes/cave_segments/seg_straight.tscn"),
                        preload("res://scenes/cave_segments/seg_branch.tscn"),
                        preload("res://scenes/cave_segments/seg_end.tscn")]

func _ready():
    pass#scale = Vector3(seg_scale,seg_scale,seg_scale)

