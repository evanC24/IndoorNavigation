import Foundation

@available(iOS 13.0, *)
/// Defines a protocol for representing obstacles in a 2D space.
/// Conforming types must implement methods to determine point inclusion, calculate distances,
/// and identify the closest edge points.
public protocol Obstacle: Codable {
    
    /// A string representing the type of the obstacle, typically for decoding purposes.
    var type: String { get }
    
    /// Determines if a specified point lies within the obstacle's boundaries.
    /// - Parameters:
    ///   - point: The `Point` to evaluate.
    ///   - safeArea: A boolean indicating whether to include a margin around the obstacle.
    /// - Returns: `true` if the point is inside the obstacle, `false` otherwise.
    func contains(point: Point, safeArea: Bool) -> Bool
    
    /// Computes the closest point on the obstacle's edge relative to a specified point.
    /// - Parameter point: The `Point` for which the closest edge point is required.
    /// - Returns: The nearest `Point` on the obstacle's edge.
    func getClosestEdgePoint(of point: Point) -> Point
    
    /// Generates a list of points representing the area covered by the obstacle.
    /// - Returns: An array of `Point` objects within the obstacle.
    func getAreaPoints() -> [Point]
    
    /// Calculates the Euclidean distance from a specified point to the obstacle.
    /// - Parameter point: The `Point` from which the distance is measured.
    /// - Returns: A `Float` value representing the distance.
    func distanceTo(point: Point) -> Float
}

/// Represents a rectangular obstacle defined by two corner points.
public struct RectangleObstacle: Obstacle, Codable {
    
    /// The top-left corner of the rectangle.
    public let topLeft: Point
    
    /// The bottom-right corner of the rectangle.
    public let bottomRight: Point
    
    /// A string describing the obstacle type.
    public let type: String = "RectangleObstacle"
    
    /// Initializes a rectangular obstacle with specified corner points.
    /// - Parameters:
    ///   - topLeft: The top-left corner of the rectangle.
    ///   - bottomRight: The bottom-right corner of the rectangle.
    public init(topLeft: Point, bottomRight: Point) {
        self.topLeft = topLeft
        self.bottomRight = bottomRight
    }
    
    /// Determines if a point is inside the rectangle, considering an optional safe area.
    /// - Parameters:
    ///   - point: The `Point` to check.
    ///   - safeArea: A flag to enable or disable the safe area margin.
    /// - Returns: `true` if the point lies within the adjusted rectangle boundaries.
    public func contains(point: Point, safeArea: Bool) -> Bool {
        let offset: Float = safeArea ? 0.35 : 0
        return point.x >= topLeft.x - offset &&
               point.x <= bottomRight.x + offset &&
               point.y >= topLeft.y - offset &&
               point.y <= bottomRight.y + offset
    }
    
    /// Identifies the closest point on the rectangle's edge relative to a given point.
    /// - Parameter point: The `Point` for which the closest edge point is calculated.
    /// - Returns: A `Point` on the rectangle's edge nearest to the input point.
    public func getClosestEdgePoint(of point: Point) -> Point {
        let clampedX = max(topLeft.x, min(bottomRight.x, point.x))
        let clampedY = max(topLeft.y, min(bottomRight.y, point.y))
        return Point(x: clampedX, y: clampedY)
    }
    
    /// Generates a grid of points covering the rectangle's area.
    /// - Returns: An array of `Point` objects representing the covered area.
    public func getAreaPoints() -> [Point] {
        let step: Float = 0.1
        var points: [Point] = []
        var y: Float = topLeft.y
        while y <= bottomRight.y {
            var x: Float = topLeft.x
            while x <= bottomRight.x {
                points.append(Point(x: roundToDecimal(x, places: 2),
                                    y: roundToDecimal(y, places: 2),
                                    heading: nil,
                                    isWalkable: false))
                x += step
            }
            y += step
        }
        return points
    }
    
    /// Calculates the shortest distance from a given point to the rectangle.
    /// - Parameter point: The `Point` for which the distance is computed.
    /// - Returns: A `Float` value indicating the distance.
    public func distanceTo(point: Point) -> Float {
        let dx = max(topLeft.x - point.x, 0, point.x - bottomRight.x)
        let dy = max(topLeft.y - point.y, 0, point.y - bottomRight.y)
        return sqrt(dx * dx + dy * dy)
    }
    
    // MARK: - Codable Conformance
    
    enum CodingKeys: String, CodingKey {
        case topLeft, bottomRight, type
    }
    
    /// Decodes a `RectangleObstacle` from a serialized representation.
    /// - Parameter decoder: The decoder instance to use.
    /// - Throws: An error if decoding fails.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.topLeft = try container.decode(Point.self, forKey: .topLeft)
        self.bottomRight = try container.decode(Point.self, forKey: .bottomRight)
    }
    
    /// Encodes the rectangle obstacle into a serialized format.
    /// - Parameter encoder: The encoder instance to use.
    /// - Throws: An error if encoding fails.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(topLeft, forKey: .topLeft)
        try container.encode(bottomRight, forKey: .bottomRight)
        try container.encode(type, forKey: .type)
    }
}

/// Represents a circular obstacle defined by its center and radius.
public class CircleObstacle: Obstacle {
    
    /// A string describing the obstacle type.
    public let type: String = "Circle"
    
    /// The center point of the circle.
    public let center: Point
    
    /// The radius of the circle.
    public let radius: Float
    
    /// Initializes a circular obstacle with a specified center and radius.
    /// - Parameters:
    ///   - center: The center `Point` of the circle.
    ///   - radius: The radius of the circle.
    public init(center: Point, radius: Float) {
        self.center = center
        self.radius = radius
    }
    
    /// Determines if a point lies within the circle's boundary.
    /// - Parameters:
    ///   - point: The `Point` to evaluate.
    ///   - safeArea: A flag to enable or disable a margin around the circle.
    /// - Returns: `true` if the point is within the circle.
    public func contains(point: Point, safeArea: Bool) -> Bool {
        let dx = point.x - center.x
        let dy = point.y - center.y
        return sqrt(dx * dx + dy * dy) <= radius
    }
    
    /// Identifies the closest point on the circle's edge relative to a given point.
    /// - Parameter point: The `Point` for which the closest edge point is calculated.
    /// - Returns: A `Point` on the circle's edge nearest to the input point.
    public func getClosestEdgePoint(of point: Point) -> Point {
        let dx = point.x - center.x
        let dy = point.y - center.y
        let distance = sqrt(dx * dx + dy * dy)
        let closestX = center.x + (dx / distance) * radius
        let closestY = center.y + (dy / distance) * radius
        return Point(x: closestX, y: closestY, heading: nil, isWalkable: true)
    }
    
    /// Generates points representing the circle's area (not implemented).
    public func getAreaPoints() -> [Point] {
        // TODO: Implement area point generation for circles.
        return []
    }
    
    /// Calculates the shortest distance from a given point to the circle.
    /// - Parameter point: The `Point` for which the distance is computed.
    /// - Returns: A `Float` value indicating the distance.
    public func distanceTo(point: Point) -> Float {
        let dx = point.x - center.x
        let dy = point.y - center.y
        return abs(sqrt(dx * dx + dy * dy) - radius)
    }
}
