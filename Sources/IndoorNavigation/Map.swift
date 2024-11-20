import Foundation
import CoreGraphics

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
    
    /// Initializes a `Map` instance with a given width, height, and a list of obstacles.
    /// - Parameters:
    ///   - width: The width of the map, representing the x-axis range.
    ///   - height: The height of the map, representing the y-axis range.
    ///   - obstacles: An array of `Obstacle` objects that define non-walkable regions on the map.
    public init(width: Float, height: Float, obstacles: [any Obstacle] /*shortestPathFactor: Float*/) {
        self.width = width
        self.height = height
        self.obstacles = obstacles
        //        self.shortestPathFactor = shortestPathFactor
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
                let isWalkable = !isInObstacleArea(Point(x: x, y: y))
                
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
        let graph = Graph(neighbors: { return self.getNeighbors(point: $0) })
        return graph.aStarSearch(start: start, end: goal, heuristic: euclideanDistance(from:to:))
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
        for neighbor in [(0, -1), (0, 1), (-1, 0), (1, 0), (-1, -1), (1, 1), (-1, 1), (1, -1)] {
            let newYIndex = yIndex + neighbor.0
            let newXIndex = xIndex + neighbor.1
            
            // Ensure the new indices are within map bounds & not in obstacles area
            if  newYIndex >= 0, newYIndex < height, newXIndex >= 0, newXIndex < width {
                let potentialNeighbor = points[newYIndex][newXIndex]
                if !isInObstacleArea(potentialNeighbor) {
                    neighbors.append(potentialNeighbor)
                }
            }
        }
        
        return neighbors
    }
    
    fileprivate func isInObstacleArea(_ potentialNeighbor: Point) -> Bool {
        return obstacles.contains {$0.contains(point: potentialNeighbor, safeArea: false)}
    }
    
}
