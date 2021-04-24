extends Node

class_name Boids

var mutex
var semaphore
var thread

var numTypes = 5
var boidResourcePath = "res://scenes/boid.tscn"
var boidList = []
var boidResource
onready var player = get_node("/root/Game/Player")

export (float, 0.0, 2.0) var collidePreventStrength=1
export (float, 0.0, 2.0) var avoidPlayerStrength=1
export (float, 0.0, 2.0) var centerStrength=1
export (float, 0.0, 2.0) var nearbySteerStrength=1
export (float, 0.0, 2.0) var copyDirStrength=1
export (float, 0.0, 8.0) var radiusCollide=4
export (float, 0.0, 16.0) var radiusAttract=8
export (float, 0.0, 32.0) var radiusPlayer=16

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
    mutex = Mutex.new()
    semaphore = Semaphore.new()
    thread=Thread.new()
    thread.start(self, "_updateBoidThreadFunc")
    
	randomize()
	boidResource = load(boidResourcePath)
    for i in range(0,100):
	    addBoid()

func getDir(node):
	return node.transform.basis.z

func dirToEuclid(vec):
	var x = vec.angle_to(Vector3(0,1,0))
	var y = Vector2(vec.x,vec.y).angle()
	var z = 3
	return Vector3(x,y,z)

func dirToRotX(vec):
	return vec.angle_to(Vector3(0,1,0))

#update data in boid 
func updateBoid(boid, other, delta):
	#if canSee(boid, other):
	if true:
		var numBoids = len(boidList)
		var pdiff = (boid.translation - other.translation)
		var dist = pdiff.length()
		var steerTarget = Vector3(0,0,0)
		
		var distFactor = 1/dist


		#prevent collision with other boids
		if dist<radiusCollide:
			steerTarget += 5*(distFactor/dist/dist-(1/radiusCollide/radiusCollide))*pdiff.normalized()*collidePreventStrength

		#steer towards nearby boid
		elif dist<radiusAttract:
			steerTarget -= (cos(
				(dist-radiusCollide)*2*PI/(radiusAttract-radiusCollide)     
			)-1)*pdiff.normalized()*nearbySteerStrength


		#make steering equal other boid
		if dist<radiusAttract:
			steerTarget += getDir(other)*copyDirStrength

		boid.steerTarget+=steerTarget

#180 degree FOV
func canSee(boid, other):
	return (boid.translation - other.translation).dot(getDir(boid))<0

#move boid
func moveBoid(boid, delta):
	boid.translation+=getDir(boid)*delta*5
	#boid.look_at(boid.steerTarget + boid.translation, Vector3(0,1,0))
	#boid.look_at(-boid.steerTarget + boid.translation, Vector3(0,1,0))
	boid.transform = boid.transform.looking_at(-boid.steerTarget + boid.translation, Vector3(0,1,0))


var imod = 0
func _process(delta):
    if imod%24==0:

        mutex.lock()

        for boid in boidList:
            boid.steerTarget = getDir(boid)

        mutex.unlock()

        semaphore.post()
    mutex.lock()
	for boid in boidList:
		moveBoid(boid, delta)
    mutex.unlock()
    imod+=1

func _updateBoidThreadFunc(delta=0.1):
    while true:
        updateBoids(delta)


func updateBoids(delta):


    semaphore.wait()

	for boid in boidList:
        #mutex.lock()
		for other in boidList:	
            pass
            if boid!=other:
                updateBoid(boid, other, delta)

		#move away from player
        var dp = (boid.translation-player.translation)
        var dist = dp.length()
        if dist<radiusPlayer:
		    boid.steerTarget += dp*(1/dist/dist-1/radiusPlayer/radiusPlayer)*100*avoidPlayerStrength

		#move to center
		boid.steerTarget += -boid.translation.normalized()*0.1*centerStrength
        #mutex.unlock()

