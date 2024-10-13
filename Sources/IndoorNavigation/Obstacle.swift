import Foundation


@available(iOS 13.0, *)
/// A protocol that defines an obstacle in a 2D space.
/// Objects conforming to this protocol must be able to identify if a point lies within them
/// and provide the closest point on their edge to a given point.
public protocol Obstacle: Identifiable, Equatable {
    /// Checks if a given point lies inside the obstacle.
    /// - Parameter point: The `Point` to check.
    /// - Returns: `true` if the point is inside the obstacle, `false` otherwise.
    func contains(point: Point) -> Bool
    
    /// Calculates the closest point on the edge of the obstacle relative to a given point.
    /// - Parameter point: The `Point` for which the closest edge point is needed.
    /// - Returns: A `Point` representing the nearest edge point of the obstacle.
    func getClosestEdgePoint(of point: Point) -> Point
}

/// Represents a rectangular obstacle in a 2D space, defined by its top-left and bottom-right corners.
public class RectangleObstacle: Obstacle {
    
    /// Unique identifier for the obstacle.
    public let id: UUID = UUID()
    /// The top-left corner of the rectangle.
    public let topLeft: Point
    /// The bottom-right corner of the rectangle.
    public let bottomRight: Point
    /// An optional offset used for adjusting boundaries (e.g., a buffer around the obstacle).
    private let offset: Float = 0.2
    
    /// Initializes a rectangular obstacle with the given top-left and bottom-right corners.
    /// - Parameters:
    ///   - topLeft: The top-left corner of the rectangle.
    ///   - bottomRight: The bottom-right corner of the rectangle.
    public init(topLeft: Point, bottomRight: Point) {
        self.topLeft = topLeft
        self.bottomRight = bottomRight
    }
    
    /// Checks if a point lies inside the rectangle.
    /// - Parameter point: The `Point` to check.
    /// - Returns: `true` if the point is within the boundaries of the rectangle, `false` otherwise.
    public func contains(point: Point) -> Bool {
        return point.x >= topLeft.x && point.x <= bottomRight.x &&
               point.y >= topLeft.y && point.y <= bottomRight.y
    }
    
    /// Checks if a point lies inside the rectangle, considering a boundary offset.
    /// - Parameter point: The `Point` to check.
    /// - Returns: `true` if the point is within the extended boundaries of the rectangle, `false` otherwise.
//    public func contains(point: Point) -> Bool {
//        return point.x >= topLeft.x - offset && point.x <= bottomRight.x + offset &&
//               point.y >= topLeft.y - offset && point.y <= bottomRight.y + offset
//    }
    
    /// Finds the closest point on the rectangle's edge to a given point.
    /// - Parameter point: The `Point` for which the closest edge point is needed.
    /// - Returns: A `Point` on the rectangle's edge that is closest to the given point.
    public func getClosestEdgePoint(of point: Point) -> Point {
        // Clamp the point's coordinates to the rectangle's boundaries.
        let closestX = max(self.topLeft.x, min(point.x, self.bottomRight.x))
        let closestY = max(self.topLeft.y, min(point.y, self.bottomRight.y))
        return Point(x: closestX, y: closestY)
    }
    
    public static func == (lhs: RectangleObstacle, rhs: RectangleObstacle) -> Bool {
        return lhs.id == rhs.id
    }
    
    /// Checks if a given rectangle is fully contained within this rectangle.
    /// - Parameter rectangle: The `RectangleObstacle` to check for containment.
    /// - Returns: `true` if the given rectangle is fully contained within the bounds of this rectangle, `false` otherwise.
    public func contains (_ rectangle: RectangleObstacle) -> Bool {
        return self.contains(point: rectangle.topLeft) && self.contains(point: rectangle.bottomRight)
    }
}

/// Represents a `Table` in the 2D space, which is modeled as a `RectangleObstacle`.
public class Table: RectangleObstacle {}

/// Represents a `Wall` in the 2D space, which is modeled as a `RectangleObstacle`.
public class Wall: RectangleObstacle {}


//struct Obstacle {
//    private let topLeft: Point
//    private let bottomRight: Point
//    private let step: Float = 0.1
//    
//    lazy var points: [(Float, Float)] = {
//        var points: [(Float, Float)] = []
//        var y: Float = topLeft.y
//        while y <= bottomRight.y {
//            var x: Float = topLeft.x
//            while x <= bottomRight.x {
//                let roundedX = roundToDecimal(x, places: 2)
//                let roundedY = roundToDecimal(y, places: 2)
//                points.append((roundedX, roundedY))
//                x += step
//            }
//            y += step
//        }
//        return points
//    }()
//    
//    init(topLeft: Point, bottomRight: Point) {
//        self.topLeft = topLeft
//        self.bottomRight = bottomRight
//    }
//    
//    func contains(point: Point) -> Bool {
//        return point.x >= topLeft.x && point.x <= bottomRight.x &&
//               point.y >= topLeft.y && point.y <= bottomRight.y
//    }
//}
