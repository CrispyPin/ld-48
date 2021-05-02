extends Node
class_name Optimized_Boids

#TODO: move toward using spherical
#TODO: more parameters
var collideDist = 4#5 # radius of boid collision
var collideStrength = 30#5 # radius of boid collision
var attractDist = 6#8 #16 # radius of boid attraction
var attractStrength = 5 # radius of boid-boid attraction
var alignDist = attractDist # radius of boid dir alignment
var alignStrength = 100 # strength of boid dir alignment
var randomStrength = 10 #0

# Boids 
var boidResourcePath = "res://scenes/boid.tscn"
var boidResource
var aliveBoids = [] # alive boids, active logic
var deadBoids = [] # dead boids, no logic 
var initNumBoids = 3000#1000#3000
var typesPerLayer = 3#8
var boidSpeed = 2 # forward movement speed 
var boidTurnSpeed = 0.5 # rotational speed 
var modFrames = 10

# 3D matrix of the boids 
var boidMatrix = null # current
var newBoidMatrix = null # new
var matrixRadius = 2 * attractDist # must be > 2 * max influence radius
# number of matrix cells in each direction
var matrixRows = 16#32#8 # should be power of 2 for easy subdivision

var matrixLength = matrixRows * matrixRadius

# Player
onready var player = get_node("/root/Game/Player")
var playerDist = matrixRows * matrixRadius # reverse radius of player attraction
var playerStrength = 0.1 # strength of player attraction 

# Thread
var matrixMutex
var boidListMutex 
var semaphore
var moveSemaphore
var thread
var moveThread
var multithread = true# use multithreading? TODO: finish implement

var MOVE_BOID_NTHREADS = 2

var spawnspread = matrixLength


var frames_sem = 0.0
var frames_main = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
    matrixMutex = Mutex.new()
    boidListMutex = Mutex.new()
    semaphore = Semaphore.new()
    moveSemaphore = Semaphore.new()

    thread=Thread.new()
    thread.start(self, "_updateBoidThreadFunc")

    #moveThread=Thread.new()
    #moveThread.start(self, "_threadMoveBoids")

    boidMatrix = createBoidMatrix(matrixRows)
    newBoidMatrix = createBoidMatrix(matrixRows)
    boidResource = load(boidResourcePath)
    createBoids(initNumBoids)


func indexToVector(v, matrix):
    return matrix[v.x][v.y][v.z]

# put boids at currect list into new matrix
# run when boids are at a potentially wrong location
# if boid is outside, it is placed at closest edge, this keeps simulation accuracy
func placeBoidsInMatrix(current,new): # thread safe

    #TODO: move origin instead

    for boid in current:
        var pos = boid.translation

        var matrixOrigin = player.translation

        pos = pos - matrixOrigin # move pos to matrix origin

        var snap = Vector3(matrixRadius, matrixRadius, matrixRadius)

        var index = pos.snapped(snap)
        index += Vector3(matrixRadius * matrixRows, matrixRadius * matrixRows, matrixRadius * matrixRows)

        # world index to index
        index /= matrixRadius

        # constrain index
        var x = max(0, min(index.x, matrixRows * 2 - 1))
        var y = max(0, min(index.y, matrixRows * 2 - 1))
        var z = max(0, min(index.z, matrixRows * 2 - 1))



        matrixMutex.lock()
        new[x][y][z].append(boid)
        matrixMutex.unlock()

func updateCubes(minIndexes, maxIndexes, current): #thread safe
    for x in range(minIndexes[0], maxIndexes[0]):
        for y in range(minIndexes[1], maxIndexes[1]):
            for z in range(minIndexes[2], maxIndexes[2]):
                updateCube(x,y,z,current)

func updateCubes_NoIndex(current): #thread safe
    for x in range(len(current)):
        for y in range(len(current[0])):
            for z in range(len(current[0][0])):
                updateCube(x,y,z,current)

# add forces, update target dir, for boids in cube
func updateCube(cx,cy,cz,current): # thread safe
    var mine = current[cx][cy][cz] # the boids that this function will operate on

    if len(mine)>0:

        # all boids that may impact mine
        var related = []
        for x in range(cx-1,cx+2):
            for y in range(cy-1,cy+2):
                for z in range(cz-1,cz+2):
                    if isInMatrix(x,y,z,current):
                        for relatedBoid in current[x][y][z]:
                            related.append(relatedBoid)

        if len(related)>0 && related != null:
            for boid in mine:
                for other in related:
                    if boid!=other:
                        updateBoid(boid,other)

        for boid in mine:
            updateBoidCommon(boid)
            updateBoidSteerTargetBuffer(boid)

# add forces, update target dir, for single boid related to other
func updateBoid(boid, other):
    var dp = boid.translation-other.translation
    var dist = dp.length()
    #TODO: parameters
    #if dist<alignDist && boid.type == other.type:
    if dist<alignDist:
        if boid.type == other.type:
            boid.newSteerTarget += other.getDir() * alignStrength
        else:
            boid.newSteerTarget -= other.getDir() * alignStrength

    if dist<collideDist:
        boid.newSteerTarget += dp * collideStrength/dist
        pass
    elif dist<attractDist && boid.type == other.type:
        boid.newSteerTarget += dp * attractStrength
        pass

#TODO: do calc here

# add forces, update target dir, for single boid unrelated to other
func updateBoidCommon(boid):
    boid.newSteerTarget += randVec(randomStrength) # random
    var dp = player.translation - boid.translation
    var dist = dp.length()
    #if dist>playerDist:
    boid.newSteerTarget += dp * playerStrength
    #TODO: do calc here

# run after boid dir update
func updateBoidSteerTargetBuffer(boid):
    boid.steerTarget = boid.newSteerTarget
    boid.newSteerTarget = boid.getDir()


# Swap buffers, clear old
func swapClearBuffers():
    matrixMutex.lock()
    boidMatrix = newBoidMatrix.duplicate() # shallow copy
    newBoidMatrix = createBoidMatrix(matrixRows)
    matrixMutex.unlock()

# Create num boids
func createBoids(num):
    for i in range(num):
        createBoid()

# Create, place, rotate boid and append it to the alive list
func createBoid():
    var boid = boidResource.instance()
    boid.init()
    respawnBoid(boid)

# Place, rotate and update type of boid and append it to the alive list
func respawnBoid(boid, pos=null, type=null): # NOT thread safe

    #TODO: transform, rotate, update type, set init dir

    if pos==null: 
        boid.translation = randVecSphere(spawnspread) + player.translation
        pos = boid.translation
    else: 
        boid.translation = pos
    if type==null: 
        boid.updateType(randi()%typesPerLayer) # TODO: gen type
        #boid.updateType(1) # TODO: gen type

    boid.rotation = randVecNoZ(PI)

    boid.steerTarget = boid.getDir()
    boid.newSteerTarget = boid.getDir()

    boidListMutex.lock()


    if boid.get_parent() != self: # needed?
        call_deferred("add_child", boid)

    aliveBoids.append(boid)
    if boid in deadBoids:
        deadBoids.remove(boid)

    boidListMutex.unlock()

# opposite of respawnBoid()
func killBoid(boid): # not thread safe due to scene tree

    boidListMutex.lock()
    if boid.get_parent() == self: # needed?
        call_deferred("remove_child", boid) 

    aliveBoids.append(boid)
    if boid in deadBoids:
        deadBoids.remove(boid)
    boidListMutex.unlock()


var imod = 0
# Called with varied delta
func _process(delta):
    imod+=1
    if imod%modFrames==0:
        frames_main+=1
        semaphore.post()
        if !multithread:
            fullBoidUpdate()
    #moveSemaphore.post()# TODO: calc delta
    boidListMutex.lock() # boidlist should not be edited while it is iterated upon
    moveBoids(aliveBoids, delta)
    boidListMutex.unlock()

func _updateBoidThreadFunc(delta=0.1):
    if multithread:
        while true:
            frames_sem+=1
            semaphore.wait()
            print(frames_sem/frames_main, " ",
                Performance.get_monitor(Performance.TIME_FPS))
            fullBoidUpdate()
            #print(Performance.get_monitor(Performance.TIME_FPS)," ",
            #      Performance.get_monitor(Performance.TIME_PROCESS)," ", 
            #      Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)," ",
            # " ")

func fullBoidUpdate():
    placeBoidsInMatrix(aliveBoids, newBoidMatrix) # cheap 
    swapClearBuffers() # semi cheap, should be almost free, guess allocation is expensive
    #updateCubes([0, 0, 0], [matrixRows*2, matrixRows*2, matrixRows*2], boidMatrix)
    if multithread:
    #if false:

        var threads = []
        #for slice in boidMatrix:

        var blockSize = 2

        for i in range(len(boidMatrix)/2):
            var thread = Thread.new()
            thread.start(self, "updateCubes_NoIndex", [boidMatrix[i], boidMatrix[i+len(boidMatrix)/2]])
            threads.append(thread)
        for thread in threads:
            thread.wait_to_finish()
    else:
        updateCubes_NoIndex(boidMatrix)

# Called with constant delta, here is where raycast goes
# if time%thing test raycast -> value in boid
# this runs on a separate thread (I think...) 
func _physics_process(delta):
    pass
#TODO: manual raycast

func _threadMoveBoids(delta=null):
    while true:
        moveSemaphore.wait()
        boidListMutex.lock()
        moveBoids(aliveBoids)
        boidListMutex.unlock()

func moveBoids(boids, delta=null):
    if delta == null:
        delta = 1/60.0
    for boid in boids:
        boid.translation+=boid.getDir()*delta*5*boidSpeed

        var current = boid.getDir()
        var target = boid.steerTarget.normalized()
        var interpolated = current.move_toward(target, boidTurnSpeed*delta*2)

        #TODO: roll controll
        var up = boid.transform.basis.y.move_toward(Vector3(0,1,0), boidTurnSpeed*delta/8.0)
        #var up = Vector3(0,1,0)
        boid.transform = boid.transform.looking_at(-interpolated + boid.translation, up)


func moveBoidsMulti(boids, delta):
    var length = len(boids)
    var maxIndex = len(boids)-1
    var boidsPerThread = 100
    var current = 0

    var threads = []
    print(length) 
    while true:
        var mi = min(current, maxIndex)
        var ma = min(current+boidsPerThread, maxIndex)

        #print(mi," ",ma," ", maxIndex)
        if current > maxIndex:
            break

        if multithread:
            thread = Thread.new()
            thread.start(self, "moveBoids", boids.slice(mi,ma,1,false))
            threads.append(thread)
        else:
            moveBoids(boids.slice(mi,ma), delta)

        current = current + boidsPerThread

    if multithread:
        for thread in threads:
            thread.wait_to_finish()

# Create empty matrix for the boids
func createBoidMatrix(rows):
    var matrix = []
    for x in range(rows*2):
        matrix.append([])
        matrix[x] = []
        for y in range(rows*2):
            matrix[x].append([])
            matrix[x][y] = []
            for z in range(rows*2):
                matrix[x][y].append([])
                matrix[x][y][z] = []
    return matrix


# move boid in current direction and
# turn towards the next target
func moveBoid(boid, delta): # thread safe
    boid.translation+=boid.getDir()*delta*5*boidSpeed

    var current = boid.getDir()
    var target = boid.steerTarget.normalized()
    var interpolated = current.move_toward(target, boidTurnSpeed*delta*2)

    #TODO: roll controll
    var up = boid.transform.basis.y.move_toward(Vector3(0,1,0), boidTurnSpeed*delta/8.0)
    #var up = Vector3(0,1,0)
    boid.transform = boid.transform.looking_at(-interpolated + boid.translation, up)



# ***** Pure util functions

# forward vector of node
func getDir(node): # thread safe
    return node.transform.basis.z

func randVec(l=1):
    return Vector3(rand_range(-l,l), rand_range(-l,l), rand_range(-l,l))

func randVecNoZ(l=1):
    return Vector3(rand_range(-l,l), rand_range(-l,l), 0)

func randVecSphere(l=1):
    return Vector3(rand_range(-l,l), rand_range(-l,l), rand_range(-l,l)).normalized()*l

func isInMatrix(x,y,z,matrix):
    return 0 <= x && x <= len(matrix)      -1\
            && 0 <= y && y <= len(matrix[0])   -1\
            && 0 <= z && z <= len(matrix[0][0])-1\
