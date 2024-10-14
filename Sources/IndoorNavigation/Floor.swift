/// A struct representing a floor in a building.
/// This struct conforms to the `Codable` protocol for easy encoding and decoding.
/// - Properties:
///   - floorId: A unique identifier for the floor.
///   - endLocations: An array of `Point` objects representing the end locations on the floor.
///   - obstacles: An array of `RectangleObstacle` objects representing obstacles present on the floor.
@available(iOS 13.0, *)
public struct Floor: Codable {
    public let floorId: String
    public let endLocations: [Point]
    public let obstacles: [RectangleObstacle]

    /// Coding keys used for encoding and decoding the `Floor` struct.
    enum CodingKeys: String, CodingKey {
        case floorId, endLocations, obstacles
    }
}






//public struct Floor: Codable {
//    public let floorId: String
//    public let endLocations: [Point]
//    public let obstacles: [RectangleObstacle]  // Assume all obstacles are of type RectangleObstacle
//
//    enum CodingKeys: String, CodingKey {
//        case floorId, endLocations, obstacles
//    }
//
//    /// Custom decoding logic to decode obstacles of type RectangleObstacle.
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.floorId = try container.decode(String.self, forKey: .floorId)
//        self.endLocations = try container.decode([Point].self, forKey: .endLocations)
//        
//        // Decode obstacles directly as an array of RectangleObstacle
//        self.obstacles = try container.decode([RectangleObstacle].self, forKey: .obstacles)
//    }
//}



//public struct Floor: Codable {
//    public let floorId: String
//    public let endLocations: [Point]
//    public let obstacles: [any Obstacle]
//    
//    enum CodingKeys: String, CodingKey {
//        case floorId, endLocations, obstacles
//    }
//    
//    /// Custom decoding logic to decode obstacles of various types.
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.floorId = try container.decode(String.self, forKey: .floorId)
//        self.endLocations = try container.decode([Point].self, forKey: .endLocations)
//        
//        // Decode obstacles
//        var obstaclesArray = [any Obstacle]()
//        var obstaclesContainer = try container.nestedUnkeyedContainer(forKey: .obstacles)
//        
//        while !obstaclesContainer.isAtEnd {
//            let obstacleContainer = try obstaclesContainer.nestedContainer(keyedBy: GenericCodingKeys.self)
//            let type = try obstacleContainer.decode(String.self, forKey: .type)
//            
//            switch type {
//            case "Table":
//                let topLeft = try obstacleContainer.decode(Point.self, forKey: .topLeft)
//                let bottomRight = try obstacleContainer.decode(Point.self, forKey: .bottomRight)
//                obstaclesArray.append(Table(topLeft: topLeft, bottomRight: bottomRight))
//                
//            case "Wall":
//                let topLeft = try obstacleContainer.decode(Point.self, forKey: .topLeft)
//                let bottomRight = try obstacleContainer.decode(Point.self, forKey: .bottomRight)
//                obstaclesArray.append(Wall(topLeft: topLeft, bottomRight: bottomRight))
//                
//            case "RectangleObstacle":
//                let topLeft = try obstacleContainer.decode(Point.self, forKey: .topLeft)
//                let bottomRight = try obstacleContainer.decode(Point.self, forKey: .bottomRight)
//                obstaclesArray.append(RectangleObstacle(topLeft: topLeft, bottomRight: bottomRight))
//                
//            case "Circle":
//                let center = try obstacleContainer.decode(Point.self, forKey: .center)
//                let radius = try obstacleContainer.decode(Float.self, forKey: .radius)
//                obstaclesArray.append(CircleObstacle(center: center, radius: radius))
//                
//            default:
//                continue
//            }
//        }
//        self.obstacles = obstaclesArray
//    }
//}
//
//
//public struct GenericCodingKeys: CodingKey {
//    public var stringValue: String
//    public var intValue: Int?
//    
//    public init?(stringValue: String) {
//        self.stringValue = stringValue
//    }
//    
//    public init?(intValue: Int) {
//        self.intValue = intValue
//        self.stringValue = "\(intValue)"
//    }
//}
