import SpriteKit

final class Mine: SKShapeNode {
    init(radius: CGFloat = 16) {
        super.init()
        path = CGPath(ellipseIn: CGRect(x: -radius, y: -radius, width: radius*2, height: radius*2), transform: nil)
        fillColor = .black; strokeColor = .red; name = "mine"; zPosition = 24
        physicsBody = SKPhysicsBody(circleOfRadius: radius)
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = PhysicsCategory.mine
        physicsBody?.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.projectile | PhysicsCategory.railBeam
        physicsBody?.collisionBitMask = 0
    }
    required init?(coder: NSCoder) { fatalError() }
}

final class Missile: SKShapeNode {
    init() {
        super.init()
        path = CGPath(roundedRect: CGRect(x: -8, y: -18, width: 16, height: 36), cornerWidth: 6, cornerHeight: 6, transform: nil)
        fillColor = .systemOrange; strokeColor = .yellow; name = "missile"; zPosition = 24
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 16, height: 36))
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = PhysicsCategory.missile
        physicsBody?.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.projectile | PhysicsCategory.railBeam
        physicsBody?.collisionBitMask = 0
    }
    required init?(coder: NSCoder) { fatalError() }
}
