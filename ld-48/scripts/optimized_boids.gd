extends Node
class_name Optimized_Boids

# list of all boids
var boids = []

# 3D matrix of boids 
var boidMatrix = null # current
var newBoidMatrix = null # new

# must be > 2 * max influence radius
var matrixRadius = 4

# should be power of 2 for easy subdivision
# number of matrix cells in each direction
var matrixRows = 8

var mutex
var semaphore
var thread

var matrixOrigin = Vector3()

# Called when the node enters the scene tree for the first time.
func _ready():
    mutex = Mutex.new()
    semaphore = Semaphore.new()
    thread = Thread.new()
    boidMatrix = createBoidMatrix(matrixRows)

func indexToVector(v, matrix):
    return matrix[v.x][v.y][v.z]

# put boids at correct new indexes 
# (thread safe, but slow)
# run when boids are at a potentially wrong location
# if boid is outside, it is placed at closest edge, this keeps simulation accuracy
func placeBoidsInMatrix(current,new):
    for boid in current:
        var pos = boid.translate

        #move pos to matrix origin
        pos = pos - matrixOrigin
        
        index = pos.snapped(Vector3(matrixRadius))
        index += Vector3(matrixRadius * matrixRows)

        # constrain index
        index.x = max(0, min(index.x, matrixRadius * matrixRadius * 2))
        index.y = max(0, min(index.y, matrixRadius * matrixRadius * 2))
        index.z = max(0, min(index.z, matrixRadius * matrixRadius * 2))

        mutex.lock()
        indexToVector(index,new).append(boid)
        mutex.unlock()

# Swap buffers, clear old
func swapClearBuffers():
    boidMatrix = newBoidMatrix
    newBoidMatrix = createBoidMatrix(matrixRows)

# Create num boids
func createBoids(num):
    for i in range(num):
        createBoid()

# Create, place and rotate boid
func createBoid():
    pass

# Place, rotate and update type of boid
func respawnBoid():
    pass

# Called with varied delta
func _process(delta):
    pass

# Called with constant delta, here is where raycast goes
func _physics_process(delta):
    pass

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
func moveBoid(boid, delta):
    pass




