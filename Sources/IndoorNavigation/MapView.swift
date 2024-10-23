import SwiftUI

/// A view that draws a map with a given width and height, and plots a path using an array of points.
@available(iOS 13.0, *)
public struct MapView: View {
    public var pathPoints: [Point]
    public var endLocation: Point?
    public var currentLocation: Point?
    public var obstacles: [any Obstacle]
    public var maxWidth: CGFloat // Real-world max width in meters
    public var maxHeight: CGFloat // Real-world max height in meters
    public var viewWidth: CGFloat // Width of the SwiftUI view in points
    public var viewHeight: CGFloat // Height of the SwiftUI view in points
    @State private var currentAmount = 0.0
    @State private var finalAmount = 1.0
    
    public init(
        pathPoints: [Point],
        endLocation: Point?,
        currentLocation: Point?,
        obstacles: [any Obstacle],
        maxWidth: CGFloat,
        maxHeight: CGFloat,
        viewWidth: CGFloat,
        viewHeight: CGFloat
    ) {
        self.pathPoints = pathPoints
        self.endLocation = endLocation
        self.currentLocation = currentLocation
        self.obstacles = obstacles
        self.maxWidth = maxWidth
        self.maxHeight = maxHeight
        self.viewWidth = viewWidth
        self.viewHeight = viewHeight
    }

    public var body: some View {
        let scaleX = viewWidth / maxWidth
        let scaleY = viewHeight / maxHeight

        if #available(iOS 17.0, *) {
            ZStack {
                
                Color.primary
                    .opacity(0.8)
                
                // Draw the path using scaled points
                Path { path in
                    guard let firstPoint = pathPoints.first else { return }
                    
                    // Start the path at the scaled first point
                    path.move(
                        to: CGPoint(
                            x: CGFloat(firstPoint.x) * scaleX,
                            y: CGFloat(firstPoint.y) * scaleY
                        )
                    )
                    
                    // Add lines to each subsequent point
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
                
                // obstacles
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
                
                // end location
                if let endLocation {
                    ZStack {
                        Image(systemName: "flag.checkered")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.background)
                    }
                    .position(
                        x: CGFloat(endLocation.x) * scaleX,
                        y: CGFloat(endLocation.y) * scaleY
                    )
                }
                
                // user position
                if let currentLocation {
                    ZStack {
                        Image(systemName: "location.fill")
                            .foregroundStyle(.blue)
                            .rotationEffect(
                                .radians(CGFloat(-currentLocation.heading) - CGFloat.pi / 4 )
                            )
                            .animation(.easeInOut, value: CGFloat(-currentLocation.heading) - CGFloat.pi / 4)
                    }
                    .position(
                        x: CGFloat(currentLocation.x) * scaleX,
                        y: CGFloat(currentLocation.y) * scaleY
                    )
                }
            }
            .border(Color.gray)
            .frame(width: viewWidth, height: viewHeight)
            .scaleEffect(finalAmount + currentAmount)
            .gesture(
                MagnifyGesture()
                    .onChanged { value in
                        currentAmount = value.magnification - 1
                    }
                    .onEnded { value in
                        finalAmount += currentAmount
                        currentAmount = 0
                    }
            )
        } else {
            // Fallback on earlier versions
        }
    }
}

@available(iOS 13.0, *)
#Preview {
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
                bottomRight: Point(x: 1.6, y: 0.5))
        ],
        maxWidth: 3,
        maxHeight: 2,
        viewWidth: 200,
        viewHeight: 200
    )
}
