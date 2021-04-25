extends MeshInstance

export var speedTarget = 10
export var acceleration = 20
var current = 0

func _process(delta):
    rotate_z(delta * current)
    if current<speedTarget:
        current += delta*acceleration
    else:
        current -= delta*acceleration
