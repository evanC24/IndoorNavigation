import Foundation

@available(iOS 13.0, *)
/// A protocol that defines an obstacle in a 2D space.
/// Objects conforming to this protocol must be able to identify if a point lies within them
/// and provide the closest point on their edge to a given point.
public protocol Obstacle: Codable {
    
    /// The type description of the obstacle, typically used for decoding.
    var type: String { get }
    
    /// Checks if a given point lies inside the obstacle.
    /// - Parameter point: The `Point` to check.
    /// - Returns: `true` if the point is inside the obstacle, `false` otherwise.
    func contains(point: Point) -> Bool
    
    /// Calculates the closest point on the edge of the obstacle relative to a given point.
    /// - Parameter point: The `Point` for which the closest edge point is needed.
    /// - Returns: A `Point` representing the nearest edge point of the obstacle.
    func getClosestEdgePoint(of point: Point) -> Point
    
    func getAreaPoints() -> [Point]
}

/// A structure representing a rectangular obstacle.
public struct RectangleObstacle: Obstacle, Codable {
    
    /// The top-left corner of the rectangular obstacle.
    public let topLeft: Point
    
    /// The bottom-right corner of the rectangular obstacle.
    public let bottomRight: Point
    
    /// Type description for the obstacle, useful during decoding.
    public let type: String = "RectangleObstacle"
    
    /// Initializes a new `RectangleObstacle` with the given top-left and bottom-right points.
    /// - Parameters:
    ///   - topLeft: The top-left corner of the rectangle.
    ///   - bottomRight: The bottom-right corner of the rectangle.
    public init(topLeft: Point, bottomRight: Point) {
        self.topLeft = topLeft
        self.bottomRight = bottomRight
    }
    
    /// Checks if a given point lies inside the obstacle.
    /// - Parameter point: The `Point` to check if is in the obstacle.
    /// - Returns: `true` if the point is within the boundaries of the rectangle; otherwise, `false`.
    public func contains(point: Point) -> Bool {
        return point.x >= topLeft.x && point.x <= bottomRight.x &&
               point.y >= topLeft.y && point.y <= bottomRight.y
    }
    
    /// Calculates the closest point on the edge of the obstacle relative to a given point.
    /// - Parameter point: The `Point` for which the closest edge point is needed.
    /// - Returns: A `Point` representing the nearest edge point of the obstacle.
    public func getClosestEdgePoint(of point: Point) -> Point {
        let clampedX = max(topLeft.x, min(bottomRight.x, point.x))
        let clampedY = max(topLeft.y, min(bottomRight.y, point.y))
        return Point(x: clampedX, y: clampedY)
    }
    
    
    /// Generates a grid of points representing the area covered by the obstacle.
    /// - Returns: An array of `Point` objects representing the grid within the obstacle's bounding box.
    public func getAreaPoints() -> [Point] {

        let step: Float = 0.1
        
        var points: [Point] = []
        
        var y: Float = self.topLeft.y
        while y <= self.bottomRight.y {
            
            var row = [Point]()
            
            var x: Float = self.topLeft.x
            
            while x <= self.bottomRight.x {
                
                let roundedX = roundToDecimal(x, places: 2)
                let roundedY = roundToDecimal(y, places: 2)

                row.append(Point(x: roundedX, y: roundedY, heading: nil, isWalkable: false))
                
                x += step
            }
            
            points.append(contentsOf: row)
            
            y += step
        }
        return points
    }

    
    
    // MARK: - Codable Conformance
    
    enum CodingKeys: String, CodingKey {
        case topLeft
        case bottomRight
        case type
    }
    
    /// Custom decoding logic to initialize from a decoder.
    /// - Parameter decoder: The decoder to use for decoding the `RectangleObstacle`.
    /// - Throws: An error if decoding fails.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.topLeft = try container.decode(Point.self, forKey: .topLeft)
        self.bottomRight = try container.decode(Point.self, forKey: .bottomRight)
    }
    
    /// Encodes this `RectangleObstacle` into the given encoder.
    /// - Parameter encoder: The encoder to use for encoding the `RectangleObstacle`.
    /// - Throws: An error if encoding fails.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(topLeft, forKey: .topLeft)
        try container.encode(bottomRight, forKey: .bottomRight)
        try container.encode(type, forKey: .type)
    }
}



//public class Table: RectangleObstacle {
//    // Designated initializer
//    public init(topLeft: Point, bottomRight: Point) {
//        super.init(type: "Table", topLeft: topLeft, bottomRight: bottomRight)
//    }
//
//    // Required initializer for decoding
//    public required init(from decoder: Decoder) throws {
//        try super.init(from: decoder)
//    }
//}
//
//public class Wall: RectangleObstacle {
//    // Designated initializer
//    public init(topLeft: Point, bottomRight: Point) {
//        super.init(type: "Wall", topLeft: topLeft, bottomRight: bottomRight)
//    }
//
//    // Required initializer for decoding
//    public required init(from decoder: Decoder) throws {
//        try super.init(from: decoder)
//    }
//}



/// Represents a circular obstacle in a 2D space.
public class CircleObstacle: Obstacle {
    
    public func getAreaPoints() -> [Point] {
        // to do
        return []
    }
    
    public let type: String = "Circle"
    public let center: Point
    public let radius: Float
    
    public init(center: Point, radius: Float) {
        self.center = center
        self.radius = radius
    }
    
    public func contains(point: Point) -> Bool {
        let dx = point.x - center.x
        let dy = point.y - center.y
        return sqrt(dx*dx + dy*dy) <= radius
    }
    
    public func getClosestEdgePoint(of point: Point) -> Point {
        let dx = point.x - center.x
        let dy = point.y - center.y
        let distance = sqrt(dx*dx + dy*dy)
        let closestX = center.x + (dx / distance) * radius
        let closestY = center.y + (dy / distance) * radius
        return Point(x: closestX, y: closestY, heading: nil, isWalkable: true)
    }
    
}


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




//@available(iOS 13.0, *)
///// A type-erased obstacle that can represent any specific obstacle type.
//public struct AnyObstacle: Obstacle, Codable {
//    public let id: UUID
//    public let type: String
//    
//    private let base: AnyObstacleBase
//    
//    // Type erasure
//    private enum AnyObstacleBase {
//        case rectangle(RectangleObstacle)
//        case circle(CircleObstacle)
//    }
//
//    // Custom initializer for decoding
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.type = try container.decode(String.self, forKey: .type)
//        
//        switch type {
//        case "Table":
//            let topLeft = try container.decode(Point.self, forKey: .topLeft)
//            let bottomRight = try container.decode(Point.self, forKey: .bottomRight)
//            let table = Table(topLeft: topLeft, bottomRight: bottomRight)
//            self.base = .rectangle(table)
//            self.id = table.id
//            
//        case "Wall":
//            let topLeft = try container.decode(Point.self, forKey: .topLeft)
//            let bottomRight = try container.decode(Point.self, forKey: .bottomRight)
//            let wall = Wall(topLeft: topLeft, bottomRight: bottomRight)
//            self.base = .rectangle(wall)
//            self.id = wall.id
//            
//        case "Circle":
//            let center = try container.decode(Point.self, forKey: .center)
//            let radius = try container.decode(Float.self, forKey: .radius)
//            let circle = CircleObstacle(center: center, radius: radius)
//            self.base = .circle(circle)
//            self.id = circle.id
//            
//        default:
//            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown obstacle type.")
//        }
//    }
//
//    // Custom encoding function
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(type, forKey: .type)
//        try container.encode(id, forKey: .id)
//        
//        switch base {
//        case .rectangle(let rectangle):
//            try container.encode(rectangle.topLeft, forKey: .topLeft)
//            try container.encode(rectangle.bottomRight, forKey: .bottomRight)
//        case .circle(let circle):
//            try container.encode(circle.center, forKey: .center)
//            try container.encode(circle.radius, forKey: .radius)
//        }
//    }
//
//    enum CodingKeys: String, CodingKey {
//        case type
//        case id
//        case topLeft
//        case bottomRight
//        case center
//        case radius
//    }
//
//    // Implement required methods for the Obstacle protocol
//    public func contains(point: Point) -> Bool {
//        switch base {
//        case .rectangle(let rectangle):
//            return rectangle.contains(point: point)
//        case .circle(let circle):
//            return circle.contains(point: point)
//        }
//    }
//    
//    public func getClosestEdgePoint(of point: Point) -> Point {
//        switch base {
//        case .rectangle(let rectangle):
//            return rectangle.getClosestEdgePoint(of: point)
//        case .circle(let circle):
//            return circle.getClosestEdgePoint(of: point)
//        }
//    }
//    
//    public static func == (lhs: AnyObstacle, rhs: AnyObstacle) -> Bool {
//        return lhs.id == rhs.id
//    }
//}
