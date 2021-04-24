extends Spatial

export var gen_depth = 10#how far ahead to generate

export var seg_scale = 16
export var dist_y = 2.5
export var dist_x = 2

export var segments = [[preload("res://models/cave_segments/seg_straight_1.fbx")],
                        [preload("res://models/cave_segments/seg_branch_1.fbx")],
                        [preload("res://models/cave_segments/seg_end_1.fbx")]]

func _ready():
    scale = Vector3(seg_scale,seg_scale,seg_scale)

