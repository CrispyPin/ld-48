extends MeshInstance

export var speedTarget = 10
export var acceleration = 20
export var current = 0

func _process(delta):
    rotate_z(delta * current)

    var factor = 1
    if abs(current)>abs(speedTarget):
        factor=abs(current)*0.05

    if current<speedTarget:
        current += delta*acceleration*factor
    else:
        current -= delta*acceleration*factor
