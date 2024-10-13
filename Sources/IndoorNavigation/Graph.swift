import Foundation

@available(iOS 13.0, *)


/// Represents a graph structure used for pathfinding, providing neighbor points and movement costs between points.
public struct Graph {
    
    /// A closure that returns the neighbors of a given point.
    public let neighbors: (Point) -> [Point]
    
    /// A closure that returns the cost of moving from one point to another.
    public let cost: (Point, Point) -> Float
    
    // Performs the A* search algorithm to find the shortest path from a starting point to an end point.
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
        ) -> ([Point: Point?], [Point: Float]) {
            
            // Initialize the priority queue with the start point.
            var frontier = PriorityQueue<Point>()
            frontier.put(start, priority: 0)

            // Maps to store the preceding point of each point and the cost to reach each point.
            var cameFrom = [Point: Point?]()
            var costSoFar = [Point: Float]()
            
            cameFrom[start] = nil
            costSoFar[start] = 0
            
            // Main A* loop: continue while there are points to explore.
            while !frontier.isEmpty {
                guard let current = frontier.get() else { break }
                
                // If the goal is reached, terminate the search.
                if current == end {
                    break
                }
                
                // Explore the neighbors of the current point.
                for next in self.neighbors(current) {
                    // Skip non-walkable points (obstacles).
                    if !next.isWalkable { continue }
                    
                    // Calculate the new cost to reach the neighbor.
                    let newCost = costSoFar[current]! + self.cost(current, next)
                    
                    // If this path to the neighbor is shorter or hasn't been explored, update the path.
                    if costSoFar[next] == nil || newCost < costSoFar[next]! {
                        costSoFar[next] = newCost
                        // Calculate priority using the heuristic (estimated distance to the end).
                        let priority = newCost + heuristic(end, next)
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
        public func nearestEdgeDistance(_ point: Point) -> Float {
            var minDistance: Float = .greatestFiniteMagnitude
            
            // Iterate through the neighbors of the point.
            for neighbor in self.neighbors(point) {
                // Skip neighbors that are obstacles.
                if !neighbor.isWalkable {
                    continue
                }
                
                // Check the neighbors of the current neighbor for obstacles.
                for adjacent in self.neighbors(neighbor) {
                    if !adjacent.isWalkable {
                        // Calculate distance to this obstacle and update the minimum distance.
                        let distance = hypot(point.x - neighbor.x, point.y - neighbor.y)
                        minDistance = min(minDistance, distance)
                    }
                }
            }
            
            // Return the distance if any were found, or 0 if none.
            return minDistance == .greatestFiniteMagnitude ? 0 : minDistance
        }
    
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




//
//// A* Search using Point
//func aStarSearch( graph: Graph, start: Point, goal: Point, heuristic: (Point, Point) -> Float) -> ([Point: Point?], [Point: Float]) {
//    var frontier = PriorityQueue<Point>()
//    frontier.put(start, priority: 0)
//    
//    var cameFrom = [Point: Point?]()
//    var costSoFar = [Point: Float]()
//    
//    cameFrom[start] = nil
//    costSoFar[start] = 0
//    
//    while !frontier.isEmpty {
//        guard let current = frontier.get() else { break }
//        
//        if current == goal {
//            break
//        }
////        let epsilon: Float = 0.5
////        if abs(current.x - goal.x) < epsilon && abs(current.y - goal.y) < epsilon {
////            break
////        }
//        
//        for next in graph.neighbors(current) {
//            if !next.isWalkable { continue }  // Skip non-walkable points (obstacles)
//            
//            let newCost = costSoFar[current]! + graph.cost(current, next)
//            if costSoFar[next] == nil || newCost < costSoFar[next]! {
//                costSoFar[next] = newCost
////                costSoFar.updateValue(newCost, forKey: next)
//                let priority = newCost + heuristic(goal, next)
//                frontier.put(next, priority: priority)
//                cameFrom[next] = current
//            }
//        }
//    }
//    
//    return (cameFrom, costSoFar)
//}













