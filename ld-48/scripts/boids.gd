extends Node

class_name Boids

var numTypes = 5
var boidResourcePath = "res://scenes/boid.tscn"
var boidList = []
var boidResource

func randVec(l=1):
    return Vector3(rand_range(-l,l), rand_range(-l,l), rand_range(-l,l))

func addBoid(position=randVec(5), type=0, rotation=randVec(PI)):


	var boid = boidResource.instance()
	boid.translation = position 
    boid.rotation = rotation
    boid.type = type
	boidList.append(boid) 
	add_child(boid)

# Called when the node enters the scene tree for the first time.
func _ready():
    randomize()
	boidResource = load(boidResourcePath)
	addBoid()
	addBoid()
	addBoid()
	addBoid()
	addBoid()
	addBoid()
	addBoid()
	addBoid()
	addBoid()
	addBoid()
	addBoid()
	addBoid()
	addBoid()
	addBoid()
	addBoid()
	addBoid()
	addBoid()
	addBoid()
	addBoid()
	addBoid()
	addBoid()
	addBoid()
	addBoid()
	addBoid()
	addBoid()
	addBoid()
	addBoid()
	addBoid()
	addBoid()

func getDir(node):
    return node.transform.basis.z

func updateBoid(boid, other, delta):
    var pdiff = boid.translation - other.translation
    if pdiff.dot(getDir(boid))<0:
        #move
        boid.translation+=boid.transform.basis.z*delta
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    for boid in boidList:	
        for other in boidList:	
            if boid!=other:
                updateBoid(boid, other, delta)
