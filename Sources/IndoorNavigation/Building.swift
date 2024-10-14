import Foundation

/// A wrapper structure for decoding floor data from JSON.
/// This struct conforms to the `Codable` protocol to facilitate encoding and decoding.
/// - Note: This struct is available starting from iOS 13.0.
@available(iOS 13.0, *)
public struct FloorsWrapper: Codable {
    /// An array of `Floor` objects representing the floors contained in the JSON data.
    public let floors: [Floor]
}

/// Loads floor data from a specified JSON file and retrieves details for a specific floor.
/// - Parameters:
///   - fileName: The name of the JSON file (without extension) located in the app bundle.
///   - floorId: The identifier of the floor to retrieve data for.
/// - Returns: A tuple containing an array of end locations and an array of obstacles if successful,
///            or `nil` if the file could not be found, if decoding fails, or if no floor with the given ID is found.
/// - Note: This function is available starting from iOS 13.0.
@available(iOS 13.0, *)
public func loadFloorData(from fileName: String, for floorId: String) -> (endLocations: [Point], obstacles: [RectangleObstacle])? {
    // Get the URL for the file in the app bundle
    guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: "json") else {
        print("Failed to find file: \(fileName)")
        return nil
    }
    
    do {
        // Read the data from the file
        let jsonData = try Data(contentsOf: fileURL)
        
        // Decode the JSON into the `FloorsWrapper`
        let decodedData = try JSONDecoder().decode(FloorsWrapper.self, from: jsonData)
        
        // Search for the floor with the given ID
        guard let floor = decodedData.floors.first(where: { $0.floorId == floorId }) else {
            print("No floor found with ID: \(floorId)")
            return nil
        }
        
        // Return the endLocations and obstacles of the found floor
        return (floor.endLocations, floor.obstacles)
    } catch {
        print("Failed to decode JSON: \(error)")
        return nil
    }
}
