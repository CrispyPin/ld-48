extends Node




var boidResourcePath = "res://scenes/boid.tscn"
var boidList = []
var boidResource

func addBoid(position=null, type=0):
    if position==null:
        position = Vector3(1,1,1)

    var boid = boidResource.instance()
    boid.translation = position 
    boidList.append(boid) 
    add_child(boid)

# Called when the node enters the scene tree for the first time.
func _ready():
    boidResource = load(boidResourcePath)
    addBoid()

    


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
