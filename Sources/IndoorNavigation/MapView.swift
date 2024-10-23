import SwiftUI

/// A view that draws a map with a given width and height, and plots a path using an array of points.
@available(iOS 15.0, *)
public struct MapView: View {
    public var pathPoints: [Point]
    public var endLocation: Point?
    public var currentLocation: Point?
    public var obstacles: [any Obstacle]
    public var maxWidth: CGFloat // Real-world max width in meters
    public var maxHeight: CGFloat // Real-world max height in meters
    public var viewWidth: CGFloat // Width of the SwiftUI view in points
    public var viewHeight: CGFloat // Height of the SwiftUI view in points
    public var isGestureEnabled: Bool = false
    
    @State private var currentScale: CGFloat = 1.0
    @State private var finalScale: CGFloat = 1.0
    @State private var currentRotation: Angle = .zero
    @State private var finalRotation: Angle = .zero
    @State private var currentOffset: CGSize = .zero
    @State private var finalOffset: CGSize = .zero
    
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
                        .frame(width: 24, height: 24)
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
                        .animation(.easeOut, value: (CGFloat(-currentLocation.heading) - CGFloat.pi / 4))
                        .position(
                            x: CGFloat(currentLocation.x) * scaleX,
                            y: CGFloat(currentLocation.y) * scaleY
                        )
                }
            }
            .frame(width: viewWidth, height: viewHeight)
            .scaleEffect(zoomScale)
            .rotationEffect(finalRotation + currentRotation)
            .offset(x: finalOffset.width + currentOffset.width, y: finalOffset.height + currentOffset.height)
            .clipped() // Ensure the map stays within bounds
            .gesture(
                SimultaneousGesture(
                    MagnificationGesture()
                        .onChanged { value in currentScale = value }
                        .onEnded { value in
                            if finalScale * currentScale < 1 {
                                finalScale = 1
                            } else if finalScale * currentScale > 3 {
                                finalScale = 3
                            } else {
                                finalScale *= currentScale
                            }
                            currentScale = 1
                        },
                    RotationGesture()
                        .onChanged { angle in currentRotation = angle }
                        .onEnded { angle in
                            finalRotation += currentRotation
                            currentRotation = .zero
                        }
                )
                .simultaneously(with:
                                    DragGesture()
                    .onChanged { value in
                        currentOffset = value.translation
                    }
                    .onEnded { value in
                        finalOffset.width = applyBoundaryConstraints(value: finalOffset.width + currentOffset.width, withZoom: zoomScale)
                        finalOffset.height = applyBoundaryConstraints(value: finalOffset.height + currentOffset.height, withZoom: zoomScale)
                        currentOffset = .zero
                    }
                               )
            )
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
    
    // Function to reset zoom, rotation, and offset
    private func resetTransformations() {
        withAnimation {
            finalScale = 1.0
            finalRotation = .zero
            finalOffset = .zero
        }
    }
    
    // Function to zoom in
    private func zoomIn() {
        withAnimation {
            finalScale = finalScale * 1.5 > 3 ? 3 : finalScale * 1.5
        }
    }
    
    // Function to zoom out
    private func zoomOut() {
        withAnimation {
            finalScale = finalScale / 1.5 < 1 ? 1 : finalScale / 1.5
        }
    }

    private func applyBoundaryConstraints(value: CGFloat, withZoom zoomScale: CGFloat) -> CGFloat {
        // Define your boundaries
        let maxOffsetX = (viewWidth * zoomScale - viewWidth) / 2
        let maxOffsetY = (viewHeight * zoomScale - viewHeight) / 2
        
        // Apply your constraints to the value
        return min(max(value, -maxOffsetX), maxOffsetX) // Adjust for X dimension
        // You should implement similar logic for Y if needed
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
