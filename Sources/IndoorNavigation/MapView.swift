import SwiftUI

/// A SwiftUI view that visually represents a navigable map with features including paths, obstacles, and interactive transformations.
/// This view supports dynamic scaling, panning, and rotation for enhanced navigation and visualization.
/// - Available: iOS 15.0+
///
/// ## Features
/// - Displays a 2D map with obstacles and a predefined path.
/// - Marks the current location and the target location with customizable icons.
/// - Interactive gestures such as zoom, pan, and reset transformations.
/// - Fully customizable dimensions for real-world and view coordinates.
///
/// ## Usage
/// This view is intended for applications that require map rendering and visualization, such as navigation apps or spatial planning tools.
@available(iOS 15.0, *)
public struct MapView: View {
    // MARK: - Properties
    
    /// The list of points defining the path to be drawn on the map.
    public var pathPoints: [Point]
    
    /// The end location of the path, represented as a `Point`.
    public var endLocation: Point?
    
    /// The current location of the user or entity, represented as a `Point`.
    public var currentLocation: Point?
    
    /// An array of obstacles to be drawn on the map. Supports any type conforming to the `Obstacle` protocol.
    public var obstacles: [any Obstacle]
    
    /// The maximum real-world width of the map in meters.
    public var maxWidth: CGFloat
    
    /// The maximum real-world height of the map in meters.
    public var maxHeight: CGFloat
    
    /// The width of the rendered view in points (screen coordinates).
    public var viewWidth: CGFloat
    
    /// The height of the rendered view in points (screen coordinates).
    public var viewHeight: CGFloat
    
    /// A Boolean flag enabling or disabling gesture interactions.
    public var isGestureEnabled: Bool
    
    // MARK: - State Variables
    
    /// The current scale factor applied during zooming gestures.
    @State private var currentScale: CGFloat = 1.0
    
    /// The final scale factor after zooming gestures.
    @State private var finalScale: CGFloat = 1.0
    
    /// The current rotation angle during rotation gestures.
    @State private var currentRotation: Angle = .zero
    
    /// The final rotation angle after rotation gestures.
    @State private var finalRotation: Angle = .zero
    
    /// The current offset applied during panning gestures.
    @State private var currentOffset: CGSize = .zero
    
    /// The final offset after panning gestures.
    @State private var finalOffset: CGSize = .zero
    
    // MARK: - Initializer
    
    /// Creates a `MapView` instance with specified properties.
    /// - Parameters:
    ///   - pathPoints: The list of points forming the path to render.
    ///   - endLocation: The target location as a `Point`, optional.
    ///   - currentLocation: The current location as a `Point`, optional.
    ///   - obstacles: An array of obstacles conforming to `Obstacle`.
    ///   - maxWidth: The real-world width of the map in meters.
    ///   - maxHeight: The real-world height of the map in meters.
    ///   - viewWidth: The width of the SwiftUI view in points.
    ///   - viewHeight: The height of the SwiftUI view in points.
    ///   - enableGestures: A flag to enable or disable gestures (default is `false`).
    public init(
        pathPoints: [Point],
        endLocation: Point?,
        currentLocation: Point?,
        obstacles: [any Obstacle],
        maxWidth: CGFloat,
        maxHeight: CGFloat,
        viewWidth: CGFloat,
        viewHeight: CGFloat,
        enableGestures: Bool = false
    ) {
        self.pathPoints = pathPoints
        self.endLocation = endLocation
        self.currentLocation = currentLocation
        self.obstacles = obstacles
        self.maxWidth = maxWidth
        self.maxHeight = maxHeight
        self.viewWidth = viewWidth
        self.viewHeight = viewHeight
        self.isGestureEnabled = enableGestures
    }
    
    
    // MARK: - Body
    
    public var body: some View {
        let scaleX = viewWidth / maxWidth
        let scaleY = viewHeight / maxHeight
        let zoomScale = finalScale * currentScale
        
        HStack {
            ZStack {
                Color.primary.opacity(0.8) // Background color
                
                // Draw the path
                Path { path in
                    guard let firstPoint = pathPoints.first else { return }
                    path.move(to: CGPoint(
                        x: CGFloat(firstPoint.x) * scaleX,
                        y: CGFloat(firstPoint.y) * scaleY
                    ))
                    for point in pathPoints.dropFirst() {
                        path.addLine(
                            to: CGPoint(
                                x: CGFloat(point.x) * scaleX,
                                y: CGFloat(point.y) * scaleY
                            )
                        )
                    }
                }
                .stroke(Color.blue, lineWidth: 2)
                
                // Draw obstacles
                ForEach(obstacles.indices, id: \.self) { index in
                    if let rectObstacle = obstacles[index] as? RectangleObstacle {
                        Rectangle()
                            .fill(Color.gray.opacity(0.9))
                            .frame(
                                width: CGFloat(rectObstacle.bottomRight.x - rectObstacle.topLeft.x) * scaleX,
                                height: CGFloat(rectObstacle.bottomRight.y - rectObstacle.topLeft.y) * scaleY
                            )
                            .position(
                                x: CGFloat(rectObstacle.topLeft.x) * scaleX +
                                (CGFloat(rectObstacle.bottomRight.x - rectObstacle.topLeft.x) * scaleX / 2),
                                y: CGFloat(rectObstacle.topLeft.y) * scaleY +
                                (CGFloat(rectObstacle.bottomRight.y - rectObstacle.topLeft.y) * scaleY / 2)
                            )
                    }
                }
                
                // End location
                if let endLocation = endLocation {
                    Image(systemName: "flag.checkered")
                        .resizable()
                        .frame(width: 12, height: 12)
                        .foregroundStyle(.background)
                        .position(
                            x: CGFloat(endLocation.x) * scaleX,
                            y: CGFloat(endLocation.y) * scaleY
                        )
                }
                
                // Current location
                if let currentLocation = currentLocation {
                    Image(systemName: "location.fill")
                        .foregroundStyle(.blue)
                        .rotationEffect(.radians(CGFloat(-currentLocation.heading) - CGFloat.pi / 4))
//                        .animation(.easeOut, value: (CGFloat(-currentLocation.heading) - CGFloat.pi / 4))
                        .position(
                            x: CGFloat(currentLocation.x) * scaleX,
                            y: CGFloat(currentLocation.y) * scaleY
                        )
                }
            }
            .frame(width: viewWidth, height: viewHeight)
            .scaleEffect(zoomScale)
//            .rotationEffect(finalRotation + currentRotation)
            .offset(x: finalOffset.width + currentOffset.width, y: finalOffset.height + currentOffset.height)
            .clipped()
//            .gesture(
//                SimultaneousGesture(
//                    MagnificationGesture()
//                        .onChanged { value in
//                            let potentialScale = finalScale * value
//                            currentScale = max(1 / finalScale, min(3 / finalScale, value)) // Constrain the current scale
//                        }
//                        .onEnded { value in
//                            let potentialScale = finalScale * currentScale
//                            finalScale = max(1, min(3, potentialScale)) // Constrain the final scale
//                            currentScale = 1
//                        },
//                    DragGesture()
//                        .onChanged { value in
//                            let zoomScale = finalScale * currentScale
//                            dump(value)
//                            currentOffset.width = applyBoundaryConstraints(value: finalOffset.width + value.translation.width, withZoom: zoomScale)
//                            currentOffset.height = applyBoundaryConstraints(value: finalOffset.height + value.translation.height, withZoom: zoomScale)
//                        }
//                        .onEnded { value in
//                            let zoomScale = finalScale * currentScale
//                            finalOffset.width = applyBoundaryConstraints(value: finalOffset.width + value.translation.width, withZoom: zoomScale)
//                            finalOffset.height = applyBoundaryConstraints(value: finalOffset.height + value.translation.height, withZoom: zoomScale)
//                            currentOffset = .zero
//                        }
//
//                )
//            )

            
            buttons
        }
    }
    
    private var buttons: some View {
        VStack {
            zoomInButton
            zoomOutButton
            resetButton
        }
        .padding()
    }
    
    private var zoomInButton: some View {
        Button(action: zoomIn) {
            Image(systemName: "plus.circle")
                .padding()
                .foregroundStyle(.background)
                .background(Color.primary.opacity(0.8))
                .clipShape(Circle())
                .shadow(radius: 5)
        }
    }
    
    private var zoomOutButton: some View {
        Button(action: zoomOut) {
            Image(systemName: "minus.circle")
                .padding()
                .foregroundStyle(.background)
                .background(Color.primary.opacity(0.8))
                .clipShape(Circle())
                .shadow(radius: 5)
        }
    }
    
    // Reset button to bring zoom, rotation, and offset back to original state.
    private var resetButton: some View {
        Button(action: resetTransformations) {
            Image(systemName: "arrow.uturn.backward.circle")
                .padding()
                .foregroundStyle(.background)
                .background(Color.primary.opacity(0.8))
                .clipShape(Circle())
                .shadow(radius: 5)
        }
    }
    
    
    /// Resets the zoom, rotation, and panning transformations to their default states.
    private func resetTransformations() {
        withAnimation {
            finalScale = 1.0
            finalRotation = .zero
            finalOffset = .zero
        }
    }
    
    /// Increases the zoom level with constraints.
    private func zoomIn() {
        withAnimation {
            finalScale = finalScale * 1.5 > 3 ? 3 : finalScale * 1.5
        }
    }
    
    /// Decreases the zoom level with constraints.
    private func zoomOut() {
        withAnimation {
            finalScale = finalScale / 1.5 < 1 ? 1 : finalScale / 1.5
        }
    }

    /// Applies boundary constraints to the panning offset.
    /// - Parameters:
    ///   - value: The proposed offset value.
    ///   - zoomScale: The current zoom scale.
    /// - Returns: The constrained offset value.
    private func applyBoundaryConstraints(value: CGFloat, withZoom zoomScale: CGFloat) -> CGFloat {
        let maxOffsetX = (viewWidth * zoomScale - viewWidth) / 2
        let maxOffsetY = (viewHeight * zoomScale - viewHeight) / 2
        
        return min(max(value, -maxOffsetX), maxOffsetX)
    }
}

@available(iOS 15.0, *)
struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(
            pathPoints: [
                Point(x: 0.1, y: 0.1),
                Point(x: 0.2, y: 0.3),
                Point(x: 0.3, y: 0.7),
                Point(x: 0.4, y: 1.5),
                Point(x: 0.9, y: 0.8),
                Point(x: 3, y: 2)
            ],
            endLocation: Point(x: 3, y: 2),
            currentLocation: Point(x: 1.5, y: 1.8),
            obstacles: [
                RectangleObstacle(
                    topLeft: Point(x: 0.3, y: 0),
                    bottomRight: Point(x: 1.6, y: 0.5)
                )
            ],
            maxWidth: 3,
            maxHeight: 2,
            viewWidth: 200,
            viewHeight: 200
        )
    }
}
