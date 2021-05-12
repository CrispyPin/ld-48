extends Node
#TODO lag spike
class_name Boids

var mutex
var semaphore
var thread
var initNumBoid = 1000
#var initNumBoid = 300
var boidSpeed = 2

#var turnspeed = 1
var turnspeed = 0.5

#num STARTING types
var numTypes = 6

var boidResourcePath = "res://scenes/boid.tscn"
var boidList = []
var boidResource

var framesPerUpdate = 10

var boidDeadPos = Vector3(0,100,0)

onready var player = get_node("/root/Game/Player")

#export (float, 0.0, 2.0) var collidePreventStrength=1
var collidePreventStrength=2
#export (float, 0.0, 2.0) var avoidPlayerStrength=1
var avoidPlayerStrength=2
#export (float, 0.0, 2.0) var centerStrength=1
var centerStrength=0.3
#export (float, 0.0, 2.0) var nearbySteerStrength=1
var nearbySteerStrength=2
#export (float, 0.0, 2.0) var copyDirStrength=1
var copyDirStrength=2
#export (float, 0.0, 8.0) var radiusCollide=4
var radiusCollide=5.209
#export (float, 0.0, 16.0) var radiusAttract=8
var radiusAttract=16
#export (float, 0.0, 128.0) var radiusPlayer=64
#var radiusPlayer=32
var radiusPlayer=64
#export (float, 0.0, 256.0) var radiusDie=512
#export (float, 1.0, 256.0) var radiusSpawnSpread=64
var radiusSpawnSpread=64
var radiusDie=radiusSpawnSpread*6

var outOfBoids = false

func randVec(l=1):
	return Vector3(rand_range(-l,l), rand_range(-l,l), rand_range(-l,l))

func randVecNoZ(l=1):
	return Vector3(rand_range(-l,l), rand_range(-l,l), 0)

func addBoid(position=randVec(40), type=randi()%numTypes, rotation=randVecNoZ(PI)):
	var boid = boidResource.instance()
	boid.rotation = rotation
	boid.steerTarget = getDir(boid)
	boid.oldSteerTarget = getDir(boid)
	boid.init(type)
	boidList.append(boid)

	respawnBoid(boid, null)

	#not performant, but I don't care
	boid.isAlive = false
	killBoid(boid)

func tryRespawnBoid(num=1, pos=null):
	if outOfBoids:
		return num

	outOfBoids=true
	for boid in boidList:
		if !boid.isAlive:
			outOfBoids=false

	if outOfBoids:
		return num

	for boid in boidList:
		if !boid.isAlive:
			respawnBoid(boid, pos)
			num-=1
		if num == 0:
			return num
	return num


func respawnBoid(boid, pos=null):
	if pos == null:
		boid.translation = Vector3(rand_range(-1,1), rand_range(-1,1), rand_range(-1,1))
		boid.translation = boid.translation.normalized()*radiusSpawnSpread + player.translation + Vector3(0,-radiusSpawnSpread*5,0)
	else:
		boid.translation = pos
	boid.isAlive = true
	boid.show()
	boid.setActiveEnabled(true)

	boid.reInit(-player.translation.y/300.0 + randi()%3)

	if boid.get_parent() != self:
		add_child(boid)
	#print(boid.translation)
	#boid.set_process(false)

func killBoid(boid):
	boid.translation = boidDeadPos
	boid.hide()
	outOfBoids=false
	boid.setActiveEnabled(false)
	if boid.get_parent() == self:
		remove_child(boid)
	#print("boid killed")
	#boid.set_process(false)

# Called when the node enters the scene tree for the first time.
func _ready():
	mutex = Mutex.new()
	semaphore = Semaphore.new()
	thread=Thread.new()
	thread.start(self, "_updateBoidThreadFunc")

	randomize()
	boidResource = load(boidResourcePath)
	for i in range(0,initNumBoid):
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


		##prevent collision with other boids
		if dist<radiusCollide:
			steerTarget += 5*(distFactor/dist/dist-(1/radiusCollide/radiusCollide))*pdiff.normalized()*collidePreventStrength

		##steer towards nearby boid if type is equal
		elif dist<radiusAttract:
			if boid.type == other.type:
				steerTarget += (cos(
					(dist-radiusCollide)*2*PI/(radiusAttract-radiusCollide)
				)-1)*pdiff.normalized()*nearbySteerStrength*5
			else:
				steerTarget -= (cos(
					(dist-radiusCollide)*2*PI/(radiusAttract-radiusCollide)
				)-1)*pdiff.normalized()*nearbySteerStrength*5

		##make steering equal other boid if type is equal
		if dist<radiusAttract && boid.type == other.type:
			steerTarget += getDir(other)*copyDirStrength*10

		boid.steerTarget+=steerTarget

#180 degree FOV
func canSee(boid, other):
    #return (boid.translation - other.translation).dot(getDir(boid))<0
	return (other.translation - boid.translation).dot(getDir(boid))<0

#move boid
func moveBoid(boid, delta):
	boid.translation+=getDir(boid)*delta*5*boidSpeed

	#boid.look_at(boid.steerTarget + boid.translation, Vector3(0,1,0))
	#boid.look_at(-boid.steerTarget + boid.translation, Vector3(0,1,0))
	#boid.transform = boid.transform.looking_at(-boid.oldSteerTarget + boid.translation, Vector3(0,1,0))

	var current = getDir(boid)
	var target = boid.oldSteerTarget.normalized()
	var interpolated = current.move_toward(target, turnspeed*delta*2)

	#var up = target
	var up = boid.transform.basis.y.move_toward(Vector3(0,1,0), turnspeed*delta/8.0)
	#boid.transform = boid.transform.looking_at(-interpolated + boid.translation, Vector3(0,1,0))
	boid.transform = boid.transform.looking_at(-interpolated + boid.translation, up)


var imod = 0
func _process(delta):

	if imod%framesPerUpdate==0:
		semaphore.post()

	mutex.lock()
	for boid in boidList:
		if !boid.isAlive:
			killBoid(boid)
			continue
		moveBoid(boid, delta)
	mutex.unlock()
	if imod%10:


		#respawn a few boids
		tryRespawnBoid(2)

		#kill a boid
		var mostFarAwayBoid = boidList[0]
		var mostFarAwayDist = player.translation.distance_to(mostFarAwayBoid.translation)
		for boid in boidList:
			var dist = player.translation.distance_to(boid.translation)
			if dist>mostFarAwayDist:
				mostFarAwayBoid = boid
				mostFarAwayDist = dist

		mostFarAwayBoid.isAlive = false

		#print(player.translation.y)
	imod+=1


func _physics_process(delta):
	for boid in boidList:
		if !boid.isAlive:
			continue
		for ray in boid.rayCasts:
			if ray.is_colliding():
				#print(ray.get_collision_point())
				if boid.closestPoint==null:
					boid.closestPoint = ray.get_collision_point()
					boid.closestPD = boid.translation - ray.get_collision_point()
					break


	mutex.lock()
	for boid in boidList:
		boid.oldClosestPD = boid.closestPD
		boid.oldClosestPoint = boid.closestPoint
	mutex.unlock()
	for boid in boidList:
		boid.closestPoint = null

func _updateBoidThreadFunc(delta=0.1):
	while true:
		updateBoids(delta)


func updateBoids(delta):
	semaphore.wait()
	for boid in boidList:
		if !boid.isAlive:
			continue

		boid.steerTarget = getDir(boid)
		boid.steerTarget.x = 0
		boid.steerTarget = boid.steerTarget.normalized()*4


		for other in boidList:
			pass
			if boid!=other:
				updateBoid(boid, other, delta)

		#move away from player
		var dp = (boid.translation-player.translation)
		var dist = dp.length()

		if dist<radiusPlayer:
			boid.steerTarget += dp*1000.0*avoidPlayerStrength/dist

		#move towards player
		if dist>radiusPlayer*2:
			boid.steerTarget -= dp*100.0*avoidPlayerStrength/dist

		#kill boids that are far away from player
		if dist>radiusDie:
			boid.isAlive=false


		#move to center
		#boid.steerTarget += -boid.translation.normalized()*1*centerStrength


		#avoid other objects
		#if boid.oldClosestPD!=null:
			#boid.steerTarget += boid.oldClosestPD.normalized()*3000

	mutex.lock()
	for boid in boidList:
		boid.oldSteerTarget = boid.steerTarget
	mutex.unlock()


