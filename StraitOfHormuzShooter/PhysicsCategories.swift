import Foundation

/// Bitmask categories used by SpriteKit's physics engine for collision detection.
struct PhysicsCategory {
    static let none:    UInt32 = 0
    static let player:  UInt32 = 0b0001   // 1
    static let enemy:   UInt32 = 0b0010   // 2
    static let bullet:  UInt32 = 0b0100   // 4
    static let border:  UInt32 = 0b1000   // 8
}
