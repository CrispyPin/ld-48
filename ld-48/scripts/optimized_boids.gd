extends Node
class_name Optimized_Boids

#TODO: more parameters
var boidSpeed = 2 # forward movement speed 
var boidTurnSpeed = 0.5 # rotational speed 
var collideDist = 5 # radius of boid collision
var collideStrength = 5 # radius of boid collision
var attractDist = 16 # radius of boid attraction
var attractStrength = 5 # radius of boid-boid attraction

# Boids 
var boidResourcePath = "res://scenes/boid.tscn"
var boidResource
var aliveBoids = [] # alive boids, active logic
var deadBoids = [] # dead boids, no logic 
var initNumBoids = 1000

# 3D matrix of the boids 
var boidMatrix = null # current
var newBoidMatrix = null # new
var matrixRadius = 4 # must be > 2 * max influence radius
# number of matrix cells in each direction
var matrixRows = 8 # should be power of 2 for easy subdivision

var matrixMutex
var boidListMutex 
var semaphore
var thread

var matrixOrigin = Vector3()

# Called when the node enters the scene tree for the first time.
func _ready():
    matrixMutex = Mutex.new()
    boidListMutex = Mutex.new()
    semaphore = Semaphore.new()
    thread = Thread.new()
    boidMatrix = createBoidMatrix(matrixRows)
	boidResource = load(boidResourcePath)
    createBoids(initNumBoids)

func indexToVector(v, matrix):
    return matrix[v.x][v.y][v.z]

# put boids at currect list into new matrix
# run when boids are at a potentially wrong location
# if boid is outside, it is placed at closest edge, this keeps simulation accuracy
func placeBoidsInMatrix(current,new): # thread safe
    for boid in current:
        var pos = boid.translate

        
        pos = pos - matrixOrigin # move pos to matrix origin
        
        index = pos.snapped(Vector3(matrixRadius))
        index += Vector3(matrixRadius * matrixRows)

        # constrain index
        index.x = max(0, min(index.x, matrixRadius * matrixRadius * 2))
        index.y = max(0, min(index.y, matrixRadius * matrixRadius * 2))
        index.z = max(0, min(index.z, matrixRadius * matrixRadius * 2))

        matrixMutex.lock()
        indexToVector(index,new).append(boid)
        matrixMutex.unlock()

func updateCubes(minIndexes, maxIndexes, current): #thread safe
    for x in range(minIndexes[0], maxIndexes[0]):
        for y in range(minIndexes[1], maxIndexes[1]):
            for z in range(minIndexes[2], maxIndexes[2]):
                updateCube(x,y,z,current)

# add forces, update target dir, for boids in cube
func updateCube(cx,cy,cz,current): 
    # the boids that this function will operate on
    var mine = current[cx,cy,cz]

    # all boids that may impact mine
    var related = []
    for x in range(cx-1,cx+2):
        for y in range(cy-1,cy+2):
            for z in range(cz-1,cz+2):
                related.append(current[x][y][z])
    
    for boid in mine:
        for related in other:
            if boid!=related:
                updateBoid(boid,other)

# add forces, update target dir, for single boid related to other
func updateBoid(boid, other):
    pass
    #TODO: do calc here

# add forces, update target dir, for single boid unrelated to other
func updateBoidCommon(boid):
    pass
    #TODO: random
    #TODO: do calc here

# run before boid dir update
func updateBoidPre(boid):
    boid.steerTarget = boid.newSteerTarget
    boid.newSteerTarget = boid.getDir()


# Swap buffers, clear old
func swapClearBuffers():
    matrixMutex.lock()
    boidMatrix = newBoidMatrix
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
func respawnBoid(boid): # not thread safe due to scene tree

    #TODO: transform, rotate, update type, set init dir
    boid.steerTarget = boid.getDir()

    boidListMutex.lock()

    if boid.get_parent() != self: # needed?
        add_child(boid) 
    aliveBoids.append(boid)
    if boid in deadBoids:
        deadBoids.remove(boid)
    boidListMutex.unlock()

# opposite of respawnBoid()
func killBoid(boid): # not thread safe due to scene tree

    boidListMutex.lock()
    if boid.get_parent() == self: # needed?
        remove_child(boid) 

    aliveBoids.append(boid)
    if boid in deadBoids:
        deadBoids.remove(boid)
    boidListMutex.unlock()

# Called with varied delta
func _process(delta):

    placeBoidsInMatrix(aliveBoids, newBoidMatrix)
    swapClearBuffers()

    updateCubes(minIndexes, maxIndexes, boidMatrix)
   
    
    boidListMutex.lock() # boidlist should not be edited while it is iterated upon
    for boid in aliveBoids:
        moveBoid(boid, delta)
    boidListMutex.unlock()

# Called with constant delta, here is where raycast goes
# if time%thing test raycast -> value in boid
# this runs on a separate thread (I think...) 
func _physics_process(delta):
    pass
    #TODO: manual raycast

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
	var target = boid.oldSteerTarget.normalized()
	var interpolated = current.move_toward(target, turnspeed*delta*2)

    #TODO: roll controll
	var up = boid.transform.basis.y.move_toward(Vector3(0,1,0), turnspeed*delta/8.0)
	boid.transform = boid.transform.looking_at(-interpolated + boid.translation, up)

# forward vector of node
func getDir(node): # thread safe
	return node.transform.basis.z



