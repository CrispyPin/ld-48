extends Node

class_name Boids

var numTypes = 5
var boidResourcePath = "res://scenes/boid.tscn"
var boidList = []
var boidResource

func randVec(l=1):
    return Vector3(rand_range(-l,l), rand_range(-l,l), rand_range(-l,l))


func randVecNoZ(l=1):
    return Vector3(rand_range(-l,l), rand_range(-l,l), 0)

func addBoid(position=randVec(20), type=0, rotation=randVecNoZ(PI)):
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

func getDir(node):
    return node.transform.basis.z

#update data in boid 
func updateBoid(boid, other, delta):
    if canSee(boid, other):
        boid.type=1

#180 degree FOV
func canSee(boid, other):
    return (boid.translation - other.translation).dot(getDir(boid))<0

#move boid
func moveBoid(boid, delta):
    if boid.type==1:
        boid.translation+=getDir(boid)*delta

func _process(delta):
    for boid in boidList:	
        boid.type=0
        for other in boidList:	
            if boid!=other:
                updateBoid(boid, other, delta)
        moveBoid(boid, delta)

