import Foundation

/// A structure representing a point in a 2D space, with optional heading, walkability status, and a name.
public struct Point: Hashable, Codable {
    /// Internal storage for the x-coordinate.
    private var _x: Float  // Valore effettivo di x.
    /// Internal storage for the y-coordinate.
    private var _y: Float  // Valore effettivo di y.
    /// Internal storage for the optional heading.
    private var _heading: Float?  // Valore effettivo di heading.
    /// Indicates whether the point is walkable.
    public var isWalkable: Bool  // Indicates if the point is walkable.
    /// An optional name for the point.
    public var name: String?  // An optional name for identifying the point.

    /// Tolerance used for comparing floating-point coordinates to account for minor precision errors.
    private static let epsilon: Float = 0.1

    /// Computed property to get the x-coordinate rounded to the nearest tenth.
    /// - Returns: The x-coordinate rounded to the nearest tenth.
    public var x: Float {
        return round(_x * 10) / 10
    }

    /// Computed property to get the y-coordinate rounded to the nearest tenth.
    /// - Returns: The y-coordinate rounded to the nearest tenth.
    public var y: Float {
        return round(_y * 10) / 10
    }

    /// Computed property to get the heading rounded to the nearest tenth.
    /// - Returns: The heading angle (in degrees or radians) rounded to the nearest tenth.
    ///   If heading is `nil`, it defaults to `0` before rounding.
    public var heading: Float {
        return round((_heading ?? 0) * 10) / 10
    }

    /// Initializes a new point with the given x, y, heading, and name values.
    /// - Parameters:
    ///   - x: The x-coordinate of the point.
    ///   - y: The y-coordinate of the point.
    ///   - heading: An optional heading value representing the direction (angle).
    ///   - isWalkable: A boolean indicating if the point is walkable. Defaults to `true`.
    ///   - name: An optional name for the point.
    public init(x: Float, y: Float, heading: Float? = nil, isWalkable: Bool = true, name: String? = nil) {
        self._x = x
        self._y = y
        self._heading = heading
        self.isWalkable = isWalkable
        self.name = name
    }

    /// Provides a textual description of the point, useful for debugging or logging.
    /// - Returns: A string in the format "(x, y, heading, name)".
    public var description: String {
        return "(\(x), \(y), \(heading), name: \(name ?? "nil"))"
    }

    /// Custom equality operator to compare two points based on their rounded values.
    /// - Parameters:
    ///   - lhs: The left-hand side `Point` to compare.
    ///   - rhs: The right-hand side `Point` to compare.
    /// - Returns: `true` if the x and y coordinates are the same, `false` otherwise.
    public static func == (lhs: Point, rhs: Point) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }

    /// Hash function to ensure that points with similar coordinates hash to the same value.
    /// This is important for using `Point` as keys in dictionaries or in sets.
    /// - Parameter hasher: The `Hasher` used to combine the x and y values.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(Int(round(_x * 10)))
        hasher.combine(Int(round(_y * 10)))
    }

    // MARK: - Codable Conformance
    
    enum CodingKeys: String, CodingKey {
        case _x = "x"
        case _y = "y"
        case _heading = "heading"
        case isWalkable
        case name
    }
    
    /// Encodes this point into the given encoder.
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(_x, forKey: ._x)
        try container.encode(_y, forKey: ._y)
        try container.encode(_heading, forKey: ._heading)
        try container.encode(isWalkable, forKey: .isWalkable)
        try container.encode(name, forKey: .name)
    }
    
    /// Initializes a new instance of `Point` from the provided decoder.
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self._x = try container.decode(Float.self, forKey: ._x)
        self._y = try container.decode(Float.self, forKey: ._y)
        self._heading = try container.decodeIfPresent(Float.self, forKey: ._heading)
        self.isWalkable = try container.decode(Bool.self, forKey: .isWalkable)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
    }
}
