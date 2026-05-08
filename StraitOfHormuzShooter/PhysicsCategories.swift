import Foundation

struct PhysicsCategory {
    static let none: UInt32 = 0
    static let player: UInt32 = 1 << 0
    static let mine: UInt32 = 1 << 1
    static let missile: UInt32 = 1 << 2
    static let projectile: UInt32 = 1 << 3
    static let powerUp: UInt32 = 1 << 4
    static let land: UInt32 = 1 << 5
    static let railBeam: UInt32 = 1 << 6
}

enum PowerUpType: CaseIterable {
    case shield, jet, rail
}
