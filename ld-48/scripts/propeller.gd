extends MeshInstance

export var speed = 10

func _process(delta):
    rotate_z(delta * speed)
