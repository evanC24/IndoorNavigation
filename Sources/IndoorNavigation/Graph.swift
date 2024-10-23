import Foundation

@available(iOS 13.0, *)


/// Represents a graph structure used for pathfinding, providing neighbor points and movement costs between points.
public struct Graph {
    
    /// A closure that returns the neighbors of a given point.
//    public let neighbors: (Point) -> [Point]
    public let neighbors: (Point) -> [Point]
    
    /// A closure that returns the cost of moving from one point to another, considering a potential previous point.
//    public let cost: (Point, Point) -> Float
    public let cost: (Point, Point, Point?) -> Float
    
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
        heuristic: (Point, Point, Point?) -> Float
//        heuristic: (Point, Point) -> Float
    ) -> ([Point: Point?], [Point: Float]) {
        
        var frontier = PriorityQueue<Point>()
        frontier.put(start, priority: 0)
        
        var cameFrom = [Point: Point?]()
        var costSoFar = [Point: Float]()
        
        cameFrom[start] = nil
        costSoFar[start] = 0
        
        while !frontier.isEmpty {
//            guard let (current, previous) = frontier.get() else { break }
            guard let current = frontier.get() else { break }
            
            // If we reached the goal, stop the search.
            guard current != end else { break }
            
            var previous: Point?
            if let p = cameFrom[current] {
                previous = p!
            }
            
            // Explore the neighbors of the current point.
            for next in self.neighbors(current) {
                if !next.isWalkable { continue }
                
                // Calculate the new cost of reaching the neighbor.
                let newCost = costSoFar[current]! + self.cost(current, next, previous)
                
                
                if costSoFar[next] == nil || newCost < costSoFar[next]! {
                    costSoFar[next] = newCost
//                    let priority = newCost + heuristic(end, next)
//                    let priority = newCost + heuristic(next, end, previous)
                    let priority = newCost + euclideanDistance(from: next, to: end)
                    frontier.put(next, priority: priority)
                    cameFrom[next] = current
                }
            }
        }
        
        return (cameFrom, costSoFar)
    }

    /// Calculates the distance to the nearest edge (or boundary of an obstacle) from a given point.
        /// - Parameter point: The point for which to find the nearest edge distance.
        /// - Returns: The distance to the nearest non-walkable neighbor, or 0 if there are no obstacles nearby.
//        public func nearestEdgeDistance(_ point: Point) -> Float {
//            var minDistance: Float = .greatestFiniteMagnitude
//            
//            // Iterate through the neighbors of the point.
//            for neighbor in self.neighbors(point) {
//                // Skip neighbors that are obstacles.
//                if !neighbor.isWalkable {
//                    continue
//                }
//                
//                // Check the neighbors of the current neighbor for obstacles.
//                for adjacent in self.neighbors(neighbor) {
//                    if !adjacent.isWalkable {
//                        // Calculate distance to this obstacle and update the minimum distance.
//                        let distance = hypot(point.x - neighbor.x, point.y - neighbor.y)
//                        minDistance = min(minDistance, distance)
//                    }
//                }
//            }
//            
//            // Return the distance if any were found, or 0 if none.
//            return minDistance == .greatestFiniteMagnitude ? 0 : minDistance
//        }
    
//    public func enhancedHeuristic(_ goal: Point, _ current: Point, _ obstacles: [any Obstacle]) -> Float {
//        let distance = hypot(goal.x - current.x, goal.y - current.y)
//      let edgeDistance = nearestEdgeDistance(current)
//        var edgeDistance: Float = 0
//        if let closestEdgePoint = obstacles.compactMap({ $0.getClosestEdgePoint(of: current)})
//            .min(by: { euclideanDistance(from: $0, to: current) < euclideanDistance(from: $1, to: current) }) {
//            edgeDistance = hypot(closestEdgePoint.x - current.x, closestEdgePoint.y - current.y)
//        }
//        
//        let alpha: Float = 0.7 // Weight for Euclidean distance
//        let beta: Float = 1 - alpha // Weight for edge distance
//        
//        return alpha * distance + beta * edgeDistance
//    }
    
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
