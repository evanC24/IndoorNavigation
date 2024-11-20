import Foundation

@available(iOS 13.0, *)

/// Represents a graph structure used for pathfinding, providing neighbor points and movement costs between points.
public struct Graph {
    
    /// A closure that returns the neighbors of a given point.
    public let neighbors: (Point) -> [Point]
    
    /// A closure that returns the cost of moving from one point to another, considering a potential previous point.
    public let cost: (Point, Point) -> Float
    
    /// Performs the A* search algorithm to find the shortest path from the start to the end point.
     /// - Parameters:
     ///   - start: The starting point of the search.
     ///   - end: The goal point of the search.
     ///   - heuristic: A function that estimates the distance from the current point to the goal.
     /// - Returns: A tuple containing:
     ///   - `cameFrom`: A dictionary that maps each point to its preceding point in the path.
     ///   - `costSoFar`: A dictionary that maps each point to the cost incurred to reach it.
    public func aStarSearch(
        start: Point,
        end: Point,
        heuristic: (Point, Point) -> Float
    ) -> [Point] {
        let path = astar(start) { point in
            point == end
        } successorFn: { point in
            self.neighbors(point)
        } heuristicFn: { point in
            heuristic(point, end)
        }
        return path ?? []
    }
}

/// Reconstructs the path from the start point to the goal point using the `cameFrom` map.
    /// - Parameters:
    ///   - cameFrom: A dictionary mapping each point to its preceding point in the path.
    ///   - start: The starting point of the path.
    ///   - goal: The goal point of the path.
    /// - Returns: An array of points representing the path from start to goal. If no valid path exists, returns an empty array.
    func reconstructPath(
        cameFrom: [Point: Point?],
        start: Point,
        goal: Point
    ) -> [Point] {
        var current = goal
        var path = [Point]()
        
        // Check if the goal is reachable from the start.
        guard cameFrom[goal] != nil else {
            print("No path found: goal is not reachable from the start.")
            return []
        }
        
        // Backtrack from the goal to the start.
        while current != start {
            path.append(current)
            if let previous = cameFrom[current] {
                current = previous!
            } else {
                // If there is no previous point, the path is incomplete.
                print("No path found: reached a dead end at \(current).")
                return []
            }
        }
        
        // Add the start point and reverse the path to get the correct order.
//            path.append(start)
        return path.reversed()
    }
