import Foundation

/// Rounds a given float to a specified number of decimal places.
/// - Parameters:
///   - number: The float value to round.
///   - places: The number of decimal places to round to.
/// - Returns: A float rounded to the specified number of decimal places.
public func roundToDecimal(_ number: Float, places: Int) -> Float {
    let divisor = pow(10.0, Float(places))
    return (number * divisor).rounded() / divisor
}

/// Converts an angle from radians to degrees.
/// - Parameter radians: The angle in radians.
/// - Returns: The equivalent angle in degrees.
public func radiansToDegrees(_ radians: Float) -> Float {
    return radians * (180.0 / Float.pi)
}

#warning ("possible remove of function")
/// Normalizes an angle to the range of -π to π.
/// - Parameter angle: The angle in radians to normalize.
/// - Returns: The normalized angle within the range of -π to π.
public func normalizeAngleToPi(_ angle: Float) -> Float {
    var normalizedAngle = angle.truncatingRemainder(dividingBy: 2 * Float.pi)
    if normalizedAngle > Float.pi {
        normalizedAngle -= 2 * Float.pi
    } else if normalizedAngle < -Float.pi {
        normalizedAngle += 2 * Float.pi
    }
    return normalizedAngle
}

/// Calculates the bearing (or angle) from a starting point to an ending point.
/// - Parameters:
///   - start: The starting point as a `Point` object.
///   - end: The ending point as a `Point` object.
/// - Returns: The bearing in radians, ranging from -π to π.
public func calculateBearing(from start: Point, to end: Point) -> Float {
    let deltaX = end.x - start.x
    let deltaY = end.y - start.y
    return atan2(deltaY, deltaX)
}

/// Computes the Manhattan distance between two points.
/// - Parameters:
///   - a: The starting point as a `Point` object.
///   - b: The ending point as a `Point` object.
/// - Returns: The Manhattan distance as a float.
public func ManhattanDistance(_ a: Point, _ b: Point) -> Float {
    return abs(a.x - b.x) + abs(a.y - b.y)
}

/// Computes the Euclidean distance between two points.
/// - Parameters:
///   - start: The starting point as a `Point` object.
///   - end: The ending point as a `Point` object.
/// - Returns: The Euclidean distance as a float.
public func euclideanDistance(from start: Point, to end: Point) -> Float {
    let deltaX = end.x - start.x
    let deltaY = end.y - start.y
    return hypot(deltaX, deltaY)
}

/// Finds the closest point on a path to a given current location.
/// - Parameters:
///   - path: An array of `Point` objects representing the path.
///   - currentLocation: The current location as a `Point`.
/// - Returns: The point on the path that is closest to the current location, or `nil` if the path is empty.
public func findClosestPathPoint(path: [Point], from currentLocation: Point) -> Point? {
    guard !path.isEmpty else { return nil }
    
//    var filteredPath = path.filter { $0 != currentLocation }
//    filteredPath.removeFirst(5)
//    return filteredPath.min(by: { euclideanDistance(from: $0, to: currentLocation) < euclideanDistance(from: $1, to: currentLocation) })
    return path.min(by: { euclideanDistance(from: $0, to: currentLocation) < euclideanDistance(from: $1, to: currentLocation) })
}

