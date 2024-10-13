import Foundation

/// A class that represents a 2D map with a specified width and height, containing obstacles and a grid of points for navigation.
/// It generates a grid of `Point` objects, categorizing them as walkable or non-walkable based on the defined obstacles.
/// The map also supports pathfinding with weighted factors for distance and obstacle proximity.
/// - Available: iOS 13.0+
@available(iOS 13.0, *)
public class Map {
    
    /// The width of the map, representing the distance along the x-axis.
    public var width: Float
    
    /// The height of the map, representing the distance along the y-axis.
    public var height: Float
    
    /// A collection of obstacles present on the map that define non-walkable areas.
    public var obstacles: [any Obstacle]
    
    /// The distance between each point in the grid, determining the resolution of the map.
    public var step: Float = 0.1
    
    /// A 2D array of `Point` objects that represents the grid of the map.
    /// Each `Point` indicates if it is walkable based on the proximity to obstacles.
    public var points: [[Point]] = []
    
    /// A factor that determines the weight given to the direct distance when calculating movement cost.
    public var shortestPathFactor: Float
    
    /// A computed property that gives the weight for proximity penalty when calculating movement cost.
    /// It is derived as the complement of `shortestPathFactor`.
    public var proximityObstacleFactor: Float { 1 - shortestPathFactor }

    /// Initializes a `Map` instance with a given width, height, and a list of obstacles.
    /// - Parameters:
    ///   - width: The width of the map, representing the x-axis range.
    ///   - height: The height of the map, representing the y-axis range.
    ///   - obstacles: An array of `Obstacle` objects that define non-walkable regions on the map.
    public init(width: Float, height: Float, obstacles: [any Obstacle], shortestPathFactor: Float) {
        self.width = width
        self.height = height
        self.obstacles = obstacles
        self.shortestPathFactor = shortestPathFactor
        self.generatePoints()
    }

    /// Generates a grid of points for the map based on the specified width, height, and step size.
    /// Each point is checked to determine if it is walkable, meaning it does not lie within any obstacle.
    ///
    /// - The generated points are stored in the `points` property as a 2D array of `Point` objects.
    /// - A point is considered walkable if it is not inside any defined obstacles.
    private func generatePoints() {
        var y: Float = 0
        while y <= height {
            var row = [Point]()
            var x: Float = 0
            while x <= width {
                let roundedX = roundToDecimal(x, places: 2)
                let roundedY = roundToDecimal(y, places: 2)
                
                // Check if the point is not inside any obstacle using the contains method.
                let isWalkable = !obstacles.contains { $0.contains(point: Point(x: x, y: y)) }
                
                row.append(Point(x: roundedX, y: roundedY, heading: nil, isWalkable: isWalkable))
                x += step
            }
            points.append(row)
            y += step
        }
    }

    
    /// Finds the path from a starting point to a goal point using the A* search algorithm.
    /// - Parameters:
    ///   - start: The starting point of the path.
    ///   - goal: The goal point of the path.
    /// - Returns: An array of `Point` representing the path from start to goal, or an empty array if no path is found.
    public func findPath(start: Point, goal: Point) -> [Point] {

        let graph = Graph(
            neighbors: { return self.getNeighbors(point: $0) },
            cost: { return self.cost($0, $1) }
            //            cost: { return euclideanDistance(from: $0, to: $1) }
        )
        
        // Perform A* search to find the shortest path, using Euclidean distance as the heuristic.
        let (cameFrom, _) = graph.aStarSearch(start: start, end: goal, heuristic: euclideanDistance)
        
        // Reconstruct and return the path from the A* search results.
        return reconstructPath(cameFrom: cameFrom, start: start, goal: goal)
    }
    
//    public func isPointTooCloseToObstacle(_ point: Point) -> Bool {
//        return obstacles.contains {
//            if let obstacle = $0 as? RectangleObstacle {
//                let closestNeighbor = obstacle.getClosestEdgePoint(of: point)
//                let distance = euclideanDistance(from: closestNeighbor, to: point)
//                return distance < bufferDistance
//            } else {
//                return false // might cause error
//            }
//        }
//    }
    
//    public func heuristic(_ goal: Point, _ current: Point) -> Float {
//        let distance = hypot(goal.x - current.x, goal.y - current.y)
////        let edgeDistance = nearestEdgeDistance(current)
//        var edgeDistance: Float = 0
//        if let closestEdgePoint = self.obstacles.compactMap({ $0.getClosestEdgePoint(of: current)})
//            .min(by: { euclideanDistance(from: $0, to: current) < euclideanDistance(from: $1, to: current) }) {
//            edgeDistance = hypot(closestEdgePoint.x - current.x, closestEdgePoint.y - current.y)
//        }
//        
//        let alpha: Float = 0.7 // Weight for Euclidean distance
//        let beta: Float = 1 - alpha // Weight for edge distance
//        
//        return alpha * distance + beta * edgeDistance
//    }
//
    
    /// Calculates the movement cost between two points, considering distance and proximity to obstacles.
    /// - Parameters:
    ///   - current: The current point.
    ///   - next: The next point to move to.
    /// - Returns: The calculated movement cost as a `Float`, where a lower value indicates a more preferable move.
    public func cost(_ current: Point,_ next: Point) -> Float {

        let distance = hypot(next.x - current.x, next.y - current.y)
        
        // Calculate a proximity penalty based on the closest obstacle
        var penalty: Float = 0
        
        if let closestObstacleEdgePoint = self.obstacles.compactMap({ $0.getClosestEdgePoint(of: next) })
            .min(by: { euclideanDistance(from: $0, to: next) < euclideanDistance(from: $1, to: next) }) {
            
            let closestBoundariesDistance = self.getClosestBoundariesDistance(from: next)
            
            let edgeDistance = euclideanDistance(from: next, to: closestObstacleEdgePoint)
            
            let closestDistance = min(closestBoundariesDistance, edgeDistance)
            
            // Invert the edge distance to create a penalty: closer points get a higher penalty
            penalty = closestDistance == 0 ? Float.greatestFiniteMagnitude : 1 / closestDistance
        }
        
        return shortestPathFactor * distance + proximityObstacleFactor * penalty
    }

    func getClosestBoundariesDistance(from point: Point) -> Float {
        let distanceToLeft = point.x
        let distanceToRight = width - point.x
        let distanceToBottom = point.y
        let distanceToTop = height - point.y
        return min(distanceToLeft, distanceToRight, distanceToBottom, distanceToTop)
    }


    /// Gets the walkable neighboring points for a given point on the map.
    /// - Parameter point: The point for which to find neighbors.
    /// - Returns: An array of `Point` representing the walkable neighboring points.
    public func getNeighbors(point: Point) -> [Point] {
        // Calculate the indices of the current point based on the grid.
        let xIndex = Int(round(point.x / step))
        let yIndex = Int(round(point.y / step))

        var neighbors = [Point]()
        
        let width = points[0].count
        let height = points.count

        // Check the four possible adjacent points (up, down, left, right).
        for neighbor in [(0, -1), (0, 1), (-1, 0), (1, 0)] {
            let newYIndex = yIndex + neighbor.0
            let newXIndex = xIndex + neighbor.1

            // Ensure the new indices are within map bounds.
            if newYIndex >= 0, newYIndex < height, newXIndex >= 0, newXIndex < width {
                let potentialNeighbor = points[newYIndex][newXIndex]
                if potentialNeighbor.isWalkable {
                    neighbors.append(potentialNeighbor)
                }
            }
        }

        return neighbors
    }
    
//    func findClosestPathPoint(from path: [Point], to currentLocation: Point) -> Point? {
////        let walkablePoints = path.filter { pathPoint in
////            !pathPoint.isWalkable && !obstacles.contains { obstacle in
////                obstacle.contains(point: pathPoint)
////            }
////        }
//        return path.min { euclideanDistance(from: $0, to: currentLocation) < euclideanDistance(from: $1, to: currentLocation)}
//    }


}


//struct Map {
//    var width: Float
//    var height: Float
//    var obstacles: [(Float, Float)]
//    var step: Float
//    
//    var points: [[Point]] = []
//
//    mutating func generatePoints() {
//        var y: Float = 0
//        while y <= height {
//            var row = [Point]()
//            var x: Float = 0
//            while x <= width {
//                let roundedX = roundToDecimal(x, places: 2)
//                let roundedY = roundToDecimal(y, places: 2)
//                let isWalkable = !obstacles.contains { $0.0 == roundedX && $0.1 == roundedY }
//                row.append(Point(x: roundedX, y: roundedY, heading: nil, isWalkable: isWalkable))
//                x += step
//            }
//            points.append(row)
//            y += step
//        }
//    }
//
////    mutating func generatePoints() {
////        var y: Float = 0
////        while y <= height {
////            var row = [Point]()
////            var x: Float = 0
////            while x <= width {
////                let roundedX = roundToDecimal(x, places: 2)
////                let roundedY = roundToDecimal(y, places: 2)
////                let isWalkable = !obstacles.contains { $0.0 == roundedX && $0.1 == roundedY }
////                row.append(Point(x: roundedX, y: roundedY, heading: nil, isWalkable: isWalkable))
////                if step > 0.1 && x + step > width {
////                    x = width
////                    break
////                }
////            }
////            points.append(row)
////            if step > 0.1 && y + step > height {
////                y = height
////                break
////            }
////        }
////    }
//
//    init(width: Float, height: Float, obstacles: [(Float, Float)], step: Float = 0.1) {
//        self.width = width
//        self.height = height
//        self.obstacles = obstacles
//        self.step = step
//        self.generatePoints()
//    }
//
//    
//    func getNeighbors(point: Point) -> [Point] {
//        let xIndex = Int(round(point.x / step))
//        let yIndex = Int(round(point.y / step))
//
//        var neighbors = [Point]()
//
//        let width = points[0].count
//        let height = points.count
//
//        let bufferDistance: Float = 0.3
//
//        func isPointTooCloseToObstacle(_ point: Point) -> Bool {
//            return obstacles.contains { obstacle in
//                let distance = euclideanDistance(Point(x: obstacle.0, y: obstacle.1), point)
//                return distance < bufferDistance
//            }
//        }
//
//        for neighbor in [(0, -1), (0, 1), (-1, 0), (1, 0)] {
//            let newYIndex = yIndex + neighbor.0
//            let newXIndex = xIndex + neighbor.1
//
//            if newYIndex >= 0, newYIndex < height, newXIndex >= 0, newXIndex < width {
//                let potentialNeighbor = points[newYIndex][newXIndex]
//                if potentialNeighbor.isWalkable && !isPointTooCloseToObstacle(potentialNeighbor) {
//                    neighbors.append(potentialNeighbor)
//                }
//            }
//        }
//
//        return neighbors
//    }
//
//
//    
//    func findPath( start: Point,
//                   goal: Point) -> [Point] {
//
//        let graph = Graph( neighbors: { return self.getNeighbors(point: $0) },
//                           cost: { return euclideanDistance($0, $1)})
//        
//        let (cameFrom, _) = graph.aStarSearch(start: start, goal: goal, heuristic: euclideanDistance)
//        
//        return reconstructPath(cameFrom: cameFrom, start: start, goal: goal)
//    }
//    
//}
