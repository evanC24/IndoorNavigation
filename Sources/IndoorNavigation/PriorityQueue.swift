import Foundation

/// A generic PriorityQueue that uses a min-heap structure to store elements with associated priorities.
/// Lower priority values will be dequeued before higher priority values.
public struct PriorityQueue<T> {
    /// The underlying heap storage that contains tuples of (priority, element).
    private var heap = [(Float, T)]()
    
    /// A Boolean property that checks if the priority queue is empty.
    public var isEmpty: Bool {
        return heap.isEmpty
    }
    
    /// Inserts an element into the priority queue with the specified priority.
    ///
    /// - Parameters:
    ///   - element: The element to be added to the queue.
    ///   - priority: The priority of the element. Lower values have higher priority.
    public mutating func put(_ element: T, priority: Float) {
        heap.append((priority, element))
        heapifyUp(from: heap.count - 1)
    }
    
    /// Removes and returns the element with the highest priority (the lowest priority value).
    ///
    /// - Returns: The element with the highest priority, or `nil` if the queue is empty.
    public mutating func get() -> T? {
        guard !heap.isEmpty else { return nil }
        if heap.count == 1 {
            return heap.removeFirst().1
        } else {
            let first = heap.first?.1
            heap[0] = heap.removeLast()
            heapifyDown(from: 0)
            return first
        }
    }
    
    /// Adjusts the heap structure upwards after an insertion to maintain the min-heap property.
    ///
    /// - Parameter index: The index of the newly inserted element.
    private mutating func heapifyUp(from index: Int) {
        var childIndex = index
        let child = heap[childIndex]
        var parentIndex = (childIndex - 1) / 2
        
        // Keep swapping the element with its parent while it has a lower priority value.
        while childIndex > 0 && child.0 < heap[parentIndex].0 {
            heap[childIndex] = heap[parentIndex]
            childIndex = parentIndex
            parentIndex = (childIndex - 1) / 2
        }
        heap[childIndex] = child
    }
    
    /// Adjusts the heap structure downwards after a removal to maintain the min-heap property.
    ///
    /// - Parameter index: The index of the element to adjust downwards.
    private mutating func heapifyDown(from index: Int) {
        var parentIndex = index
        let count = heap.count
        let element = heap[parentIndex]
        
        while true {
            let leftChildIndex = 2 * parentIndex + 1
            let rightChildIndex = 2 * parentIndex + 2
            var swapIndex = parentIndex
            
            // Compare the parent with its left child.
            if leftChildIndex < count && heap[leftChildIndex].0 < heap[swapIndex].0 {
                swapIndex = leftChildIndex
            }
            
            // Compare the current smallest between parent and left child with the right child.
            if rightChildIndex < count && heap[rightChildIndex].0 < heap[swapIndex].0 {
                swapIndex = rightChildIndex
            }
            
            // If no swaps are needed, break out of the loop.
            if swapIndex == parentIndex {
                break
            }
            
            heap[parentIndex] = heap[swapIndex]
            parentIndex = swapIndex
        }
        heap[parentIndex] = element
    }
}
