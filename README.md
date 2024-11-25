# Indoor Navigation library

## Project Description

The objective of this project is to implement a Augmented Reality pathfinding algorithm in Swift, using a grid structure to represent a search space. The algorithm is designed to explore different movement possibilities and find the optimal path between a starting point and a destination within the grid minimizing turns and avoiding obstacles. The library also supports navigation on a map, providing a path and directional hints to reach a specific destination, and a map view to locate user location and end location.

The current user indoor position is retrieved by an external library, developed in the preovious years by an alumni of the course. This app is an upgrade of PositioningLibrary demo app developed by Rosario Galioto.
- [PositioningLibrary](https://github.com/tirannosario/PositioningLibrary) | [Demo](https://github.com/tirannosario/TestPositioningLibrary)

## Key Features

- **Pathfinding Algorithm**: Identifies the optimal path between two points in a grid using A* pathfinding algorithm.
- **Grid Configuration**: The grid, representing the map, is customizable in terms of size [width, height].
- **Collision avoidance and defining obstacles**: Obstacles (walls, tables, ecc...) can be placed to increase the complexity of the search and avoid any collision.
- **Dynamic Path Visualization**: Graphical representation, such as an directional arrow, can guide the user towards the goal location suggesting the heading and the direction to get there.
- **Map**: A map view is available and it shows the map itself and its obstacles, the user location, the selected goal location and the path, if exists, from the current user position to the selected goal position
  
## Tools used

- **Language**: Swift and SwiftUI
- **Platform**: iOS 13.0 or higher
- **Libraries Used**: PositioningLibrary, SwiftPriorityQueue.

## Data setup
A .json file must be provided to upload **end locations** and **obstacles** for each **floorId**

- **floors**: An array containing the details of each floor in the navigation space.
  - **floorId**: Unique identifier for each floor (e.g., `"f1_2"`).
  - **endLocations**: Points on the floor where users can navigate to.
    - **x, y**: Coordinates representing the location's position.
    - **heading**: Orientation of the location (currently set to `null`).
    - **isWalkable**: Indicates if the location is accessible (`true` or `false`).
    - **name**: Descriptive name of the end location (e.g., `"Porta"`).
  - **obstacles**: Array of obstacles that affect navigation.
    - **type**: Type of obstacle (e.g., `"RectangleObstacle"`).
    - **topLeft**: Coordinates of the top-left corner of the obstacle.
      - **x, y**: Position coordinates.
      - **isWalkable**: Indicates if the area is accessible.
    - **bottomRight**: Coordinates of the bottom-right corner of the obstacle.


This Swift code defines a structure for decoding floor data from JSON files. It provides a mechanism to load floor details, including end locations and obstacles, for use in an indoor navigation system.

## Loading data

### FloorsWrapper
- **floors**: An array of `Floor` objects representing the floors contained in the JSON data.

### Function: `loadFloorData`

Loads floor data from a specified JSON file and retrieves details for a specific floor.

#### Parameters

- **fileName**: The name of the JSON file (without extension) located in the app bundle.
- **floorId**: The identifier of the floor to retrieve data for.

#### Returns

A tuple containing:
- An array of end locations
- An array of obstacles

Returns `nil` if:
- The file could not be found
- Decoding fails
- No floor with the given ID is found.

### Example Implementation

Here's an example of how to implement the `loadFloorData` function in your Swift project:

```swift
// Use the function to load floor data
let fileName = "floors_data" // Name of your JSON file (floors_data.json)
let floorId = "f1_2" // ID of the floor you want to load

let (endLocations, obstacles) = loadFloorData(from: fileName, for: floorId)

if !endLocations.isEmpty {
    // do something with end locations
} else {
    // no end locations available
}

if !obstacles.isEmpty {
    // do something with obstacles
} else {
    // no obstacles available
}
```

## Map Class for 2D Navigation

The `Map` class provides a 2D grid-based representation for indoor navigation. It supports the generation of points on the map, the definition of obstacles, and the calculation of paths between points using the A* algorithm.

### Features

- **Grid-based map generation**: Creates a 2D array of `Point` objects based on the specified map dimensions.
- **Obstacle handling**: Defines non-walkable areas on the map using obstacles.
- **Pathfinding**: Supports finding the shortest path between two points using a customizable cost function that includes proximity from obstacles.

### Usage

Here is an example of how to initialize a `Map` instance and find a path between two points:

```swift
// given some obstacles and given width and heights from PositioningLibrary methods

// Create the map instance
let map = Map(width: mapWidth, height: mapHeight, obstacles: obstacles)

// Define the start and goal points
...

// Find the path using A* algorithm
let path = map.findPath(start: startPoint, goal: goalPoint)

// Print the path if found
if !path.isEmpty {
    // do something with the path
} else {
    // no path has been returned
}
```

## MapView: Maph, obstacles, user location, goal location and path visualization

This project provides a customizable SwiftUI `MapView` that visualizes a path on a 2D map, supporting various features such as predefined obstacles, path plotting, and zoom gestures. It is intended for applications that require map-based navigation or visual representation of paths with obstacles.

### Features

- **Customizable Map Size**: Define real-world dimensions for the map (width and height in meters) and visualize paths and obstacles accordingly.
- **Path Plotting**: Draws a path based on a series of `Point` objects, such as a **path**.
- **Obstacles**: Visualize obstacles on the map using `Obstacle` protocol conforming types such as `RectangleObstacle`.
- **End Location**: Display the goal or end point using a end flag marker.
- **User Location**: Dynamically show the user's current position with rotation based on heading.


### Usage
```swift
import SwiftUI

@available(iOS 13.0, *)
struct ContentView: View {
    var body: some View {
        MapView(
            pathPoints: [
                Point(x: 0.1, y: 0.1),
                Point(x: 0.2, y: 0.3),
                Point(x: 0.3, y: 0.7)
            ],
            endLocation: Point(x: 3, y: 2),
            currentLocation: Point(x: 1.5, y: 1.8),
            obstacles: [
                RectangleObstacle(
                    topLeft: Point(x: 0.3, y: 0),
                    bottomRight: Point(x: 1.6, y: 0.5)
                )
            ],
            maxWidth: 3, // Real-world width (in meters)
            maxHeight: 2, // Real-world height (in meters)
            viewWidth: 300, // SwiftUI view width (in points)
            viewHeight: 300 // SwiftUI view height (in points)
        )
    }
}
```


## Obstacle Protocol 

This repository contains the definition and implementations of the `Obstacle` protocol in Swift, designed to represent various types of obstacles in a 2D space. The protocol requires conforming types to determine if a point is within the obstacle and to calculate the closest point on its edge. Several obstacle types, including rectangles and circles, are implemented.
  
### Properties
- `type`: A string representing the type of the obstacle, useful for decoding.
  
### Required Methods
- `contains(point: Point) -> Bool`: Checks if a given point lies inside the obstacle.
- `getClosestEdgePoint(of point: Point) -> Point`: Returns the closest point on the edge relative to the input point.
- `getAreaPoints() -> [Point]`: Generates an array of `Point` objects covering the obstacle's area.
- `distanceTo(point: Point) -> Float`: Calculates the Euclidean distance from a specified point to the obstacle.
  
```swift
public protocol Obstacle: Codable {
    var type: String { get }
    func contains(point: Point) -> Bool
    func getClosestEdgePoint(of point: Point) -> Point
    func getAreaPoints() -> [Point]
    func distanceTo(point: Point) -> Float
}
```

- **Concrete Implementations**:
  - `RectangleObstacle`: Represents rectangular obstacles.
  - `CircleObstacle`: Represents circular obstacles.

### Example Usage
```swift
let rectangle = RectangleObstacle(topLeft: Point(x: 0, y: 0), bottomRight: Point(x: 5, y: 5))
let point = Point(x: 2.5, y: 2.5)

print(rectangle.contains(point: point))  // true

let closestEdge = rectangle.getClosestEdgePoint(of: Point(x: 6, y: 6))
print(closestEdge)  // Output: A point representing the closest point on the rectangle's edge.
```


## Point Structure in 2D Space

This repository contains the implementation of a `Point` structure in Swift, which models a point in a 2D space. The `Point` structure also includes additional properties such as optional heading, walkability status, and an optional name. It conforms to both the `Hashable` and `Codable` protocols, making it suitable for use in sets, dictionaries, and for encoding/decoding operations.

### Properties

- `x`: The x-coordinate, rounded to the nearest tenth.
- `y`: The y-coordinate, rounded to the nearest tenth.
- `heading`: The heading (angle), rounded to the nearest tenth, defaults to `0` if not provided.
- `isWalkable`: A boolean indicating if the point is walkable, defaults to `true`.
- `name`: An optional name for identifying the point.

### Example Usage

```swift
let point = Point(x: 10.05, y: 20.12, heading: 90.0, isWalkable: true, name: "StartPoint")

print(point.description) 
// Output: "(10.1, 20.1, 90.0, name: StartPoint)"
```

## Credits
- **Author Name**: Ivan Coppola
- **University**: University of Milan La Statale
- **Course**: MobiDev

## License

This project is distributed under the MIT License.

---
