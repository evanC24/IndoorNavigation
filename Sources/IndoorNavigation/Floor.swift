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
