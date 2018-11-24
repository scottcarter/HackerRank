import UIKit


// Matrix Layer Rotation
// https://www.hackerrank.com/challenges/matrix-rotation-algo/problem
// Practice->Algorithms->Implementation
//


// Given a matrix of rows by cols, find the length of a chain containing row, col.
// and the distance of chain from outer edge.
func chainInfo(rows:Int, cols: Int, row: Int, col: Int) -> (Int, Int) {
    
    let yDim = rows - 1 // Height of y axis
    let xDim = cols - 1  // Width of x axis
    
    var distanceFromEdge:Int
    
    if (col <= xDim/2) && (row <= yDim/2) { // Upper left quadrant (including edges).
        distanceFromEdge = min(col, row)
    }
        
    else if (col <= xDim/2) && (row >= yDim/2) { // Lower left quadrant (including edges).
        distanceFromEdge = min(col, yDim - row)
    }
        
    else if (col >= xDim/2) && (row <= yDim/2) { // Upper right quadrant (including edges).
        distanceFromEdge = min(xDim - col, row)
    }
        
    else  { //  (col >= xDim/2) && (row >= yDim/2) // Lower right quadrant (including edges).
        distanceFromEdge = min(xDim - col, yDim - row)
    }
    
    
    // Length of 4 sides of this chain
    let length = ((xDim - distanceFromEdge * 2) + (yDim - distanceFromEdge * 2)) * 2
    
    return (length, distanceFromEdge)
}




// Given an origin (row, col) and a distance along the chain containing that origin, find
// the value of the chain element at that distance.
func chainElement(matrix: [[Int]], originRow row: Int, originCol col: Int, distance d: Int, chainEdgeDistance: Int) -> Int {
    
    let yDim = matrix.count - 1
    let xDim = matrix[0].count - 1
    
    let maxY = yDim - chainEdgeDistance
    let maxX = xDim - chainEdgeDistance
    
    var distance = d
    var x = col
    var y = row
    
    enum Edge {
        case Bottom
        case Left
        case Top
        case Right
    }
    
    var edge: Edge
    
    
    // Move around 4 edges as needed, clockwise
    // We set the loop for 5 since we might be starting with a partial edge and need
    // to repeat that edge at the end.
    for _ in 0..<5 {
        
        // Note that if we are in a corner, force processing to the next edge going
        // clockwise so that we can make progress.
        if y == maxY { // Bottom edge
            if x == chainEdgeDistance { // Bottom left corner - process as left edge
                edge = .Left
            }
            else {
                edge = .Bottom
            }
        }
        else if x == chainEdgeDistance { // Left edge
            if y == chainEdgeDistance {  // Top left corner - process as top edge
                edge = .Top
            }
            else {
                edge = .Left
            }
        }
        else if y == chainEdgeDistance { // Top edge
            if x == maxX { // Top right corner - process as right edge
                edge = .Right
            }
            else {
                edge = .Top
            }
        }
        else { // x == maxX // Right edge
            if y == maxY { // Bottom right corner - process as bottom edge
                edge = .Bottom
            }
            else {
                edge = .Right
            }
        }
        
        switch edge {
        case .Bottom:
            if distance > (x - chainEdgeDistance) {
                distance -= x - chainEdgeDistance
                x = chainEdgeDistance
                y = maxY
                continue
            }
            else {
                x = x - distance
                return matrix[y][x]
            }
            
        case .Left:
            if distance > (y - chainEdgeDistance) {
                distance -= y - chainEdgeDistance
                x = chainEdgeDistance
                y = chainEdgeDistance
                continue
            }
            else {
                y = y - distance
                return matrix[y][x]
            }
            
        case .Top:
            if distance > (maxX - x) {
                distance -= maxX - x
                x = maxX
                y = chainEdgeDistance
                continue
            }
            else {
                x = x + distance
                return matrix[y][x]
            }
            
        case .Right:
            if distance > (maxY - y) {
                distance -= maxY - y
                y = maxY
                x = maxX
                continue
            }
            else {
                y = y + distance
                return matrix[y][x]
            }
        }
        
    }
    
    assertionFailure("Moved around chain more than once!  originRow \(row) originCol \(col) distance \(d)  chainEdgeDistance \(chainEdgeDistance)")
    return 0
}




// Guaranteed to have number of rows, cols between 2 and 300 inclusive per the problem specification.
func matrixRotation(matrix: [[Int]], r: Int) -> Void {
    
    let numRows = matrix.count
    let numCols = matrix[0].count
    
    var chainLengthLookup: [Int:(Int,Int)] = [:]  // Our cache to avoid unnecessary processing.
    
    for row in 0..<numRows {
        for col in 0..<numCols {
            
            // Get the chain index.  Indices start at 0 for the outermost chain and increment
            // as one moves toward inner chains.
            let nearestVertEdgeDist = min(col, numCols - col - 1)
            let nearestHorizEdgeDist = min(row, numRows - row - 1)
            
            let chainIndex = min(nearestVertEdgeDist, nearestHorizEdgeDist)
            
            var chainLength: Int
            var chainEdgeDistance: Int
            
            // If we have already found the length and edge distance of a chain
            // containing this row, col then then avoid the extra processing.
            if let (length, edgeDist) = chainLengthLookup[chainIndex] {
                chainLength = length
                chainEdgeDistance = edgeDist
            }
            else {
                (chainLength, chainEdgeDistance) = chainInfo(rows: numRows, cols: numCols, row: row, col: col)
                chainLengthLookup[chainIndex] = (chainLength, chainEdgeDistance)
            }
            
            
            // Distance to rotate along chain is the number rotations % chainLength
            let distance = r % chainLength
            
            // Lookup the element along chain that should be represented at this position.
            // No need to actually move the elements themselves.
            let elem = chainElement(matrix: matrix, originRow: row, originCol: col, distance: distance, chainEdgeDistance:chainEdgeDistance)
            
            print(elem, terminator: " ")
        }
        
        print("")
    }
    
}

// To test any failing Test cases, replace the contains of variable data with test case input.
let data = """
4 4 1
1 2 3 4
5 6 7 8
9 10 11 12
13 14 15 16
"""

let lines = data.split(separator: "\n")
var arr:[[Int]] = []

let testCaseInfo = lines[0].split(separator: " ") // [rows, cols, rotations]

for i in 1..<lines.count {
    let row = lines[i].split(separator: " ")
    let rowInt = row.map({ (s) -> Int in
        Int(s)!
    })
    arr.append(rowInt)
}

matrixRotation(matrix: arr, r: Int(testCaseInfo[2])!)

// Output
//3 4 8 12
//2 11 10 16
//1 7 6 15
//5 9 13 14


