extends Node

class_name Boids

var mutex
var semaphore
var thread
var initNumBoid = 100
var boidSpeed = 1

var numTypes = 2
var boidResourcePath = "res://scenes/boid.tscn"
var boidList = []
var boidResource

var framesPerUpdate = 5

var boidDeadPos = Vector3(0,100,0)

onready var player = get_node("/root/Game/Player")

export (float, 0.0, 2.0) var collidePreventStrength=1
export (float, 0.0, 2.0) var avoidPlayerStrength=1
export (float, 0.0, 2.0) var centerStrength=1
export (float, 0.0, 2.0) var nearbySteerStrength=1
export (float, 0.0, 2.0) var copyDirStrength=1
export (float, 0.0, 8.0) var radiusCollide=4
export (float, 0.0, 16.0) var radiusAttract=8
export (float, 0.0, 32.0) var radiusPlayer=16
export (float, 0.0, 256.0) var radiusDie=256
export (float, 0.0, 256.0) var radiusInitSpawn=64

func randVec(l=1):
    return Vector3(rand_range(-l,l), rand_range(-l,l), rand_range(-l,l))

func randVecNoZ(l=1):
    return Vector3(rand_range(-l,l), rand_range(-l,l), 0)

func addBoid(position=randVec(40), type=randi()%2, rotation=randVecNoZ(PI)):
    var boid = boidResource.instance()
    respawnBoid(boid, null)
    boid.rotation = rotation
    boid.steerTarget = getDir(boid)
    boid.oldSteerTarget = getDir(boid)
    boid.init(type)
    boidList.append(boid)
    add_child(boid)

func tryRespawnBoid(num=1, pos=null):
    for boid in boidList:
        if !boid.isAlive:
            respawnBoid(boid, pos)
            num-=1
        if num == 0:
            return
    print("out of boids!")
            

func respawnBoid(boid, pos=null):
    if pos == null:
        boid.translation = Vector3(rand_range(-1,1), rand_range(-1,1), rand_range(-1,1))
        boid.translation = boid.translation.normalized()*radiusInitSpawn + player.translation
    else:
        boid.translation = pos
    boid.isAlive = true
    boid.show()

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


        #prevent collision with other boids
        if dist<radiusCollide:
            steerTarget += 5*(distFactor/dist/dist-(1/radiusCollide/radiusCollide))*pdiff.normalized()*collidePreventStrength

        #steer towards nearby boid if type is equal
        elif dist<radiusAttract && boid.type == other.type:
            steerTarget -= (cos(
                (dist-radiusCollide)*2*PI/(radiusAttract-radiusCollide)
            )-1)*pdiff.normalized()*nearbySteerStrength


        #make steering equal other boid if type is equal
        if dist<radiusAttract && boid.type == other.type:
            steerTarget += getDir(other)*copyDirStrength

        boid.steerTarget+=steerTarget

#180 degree FOV
func canSee(boid, other):
    return (boid.translation - other.translation).dot(getDir(boid))<0

#move boid
func moveBoid(boid, delta):
    boid.translation+=getDir(boid)*delta*5*boidSpeed

    #boid.look_at(boid.steerTarget + boid.translation, Vector3(0,1,0))
    #boid.look_at(-boid.steerTarget + boid.translation, Vector3(0,1,0))
    #boid.transform = boid.transform.looking_at(-boid.oldSteerTarget + boid.translation, Vector3(0,1,0))

    var current = getDir(boid)
    var target = boid.oldSteerTarget.normalized()
    var interpolated = current.move_toward(target, delta*2)
    boid.transform = boid.transform.looking_at(-interpolated + boid.translation, Vector3(0,1,0))


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
    imod+=1

func killBoid(boid):
    boid.translation = boidDeadPos
    boid.hide()

func _physics_process(delta):
    for boid in boidList:
        if !boid.isAlive:
            continue
        for ray in boid.rayCasts:
            if ray.is_colliding():
                #print(ray.get_collision_point())
                if boid.closestPoint==null:
                    boid.closestPoint = ray.get_collision_point()
                    boid.closestPD = boid.translation
                    continue

                var pdnew = boid.translation - ray.get_collision_point()
                var pdother = boid.closestPD

                if pdnew.length()<pdother.length():
                    boid.closestPoint = ray.get_collision_point()
                    boid.closestPD = pdnew

                                
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

        for other in boidList:
            pass
            if boid!=other:
                updateBoid(boid, other, delta)

        #move away from player
        var dp = (boid.translation-player.translation)
        var dist = dp.length()

        #kill boids that are far away from player
        if dist>radiusDie:
            boid.isAlive=false

        #if dist<radiusPlayer:
        #    boid.steerTarget += dp*(1/dist/dist-1/radiusPlayer/radiusPlayer)*100*avoidPlayerStrength

        #move to center
        #boid.steerTarget += -boid.translation.normalized()*1*centerStrength

    #avoid other objects
    #for boid in boidList:
    #    for ray in boid.rayCasts:
    #        if ray.is_colliding():
    #            #print("COLLIDE!")
    #            #print(i)
    #            print(ray.get_collision_point())
    #            boid.steerTarget -= (boid.translation - ray.get_collision_point()).normalized()*10
    #            break

        if boid.oldClosestPD!=null:
            boid.steerTarget -= boid.oldClosestPD.normalized()*10

    mutex.lock()
    for boid in boidList:
        boid.oldSteerTarget = boid.steerTarget
    mutex.unlock()


