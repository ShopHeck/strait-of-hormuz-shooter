import SpriteKit

final class Bullet: SKShapeNode {
    init() {
        super.init()
        path = CGPath(rect: CGRect(x: -3, y: -10, width: 6, height: 20), transform: nil)
        fillColor = .cyan; strokeColor = .white; zPosition = 28; name = "bullet"
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 6, height: 20))
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = PhysicsCategory.projectile
        physicsBody?.contactTestBitMask = PhysicsCategory.mine | PhysicsCategory.missile
        physicsBody?.collisionBitMask = 0
    }
    required init?(coder: NSCoder) { fatalError() }
}

final class PowerUpNode: SKShapeNode {
    let type: PowerUpType
    init(type: PowerUpType) {
        self.type = type
        super.init()
        path = CGPath(ellipseIn: CGRect(x: -14, y: -14, width: 28, height: 28), transform: nil)
        fillColor = type == .shield ? .systemTeal : (type == .jet ? .systemPurple : .systemRed)
        strokeColor = .white
        name = "powerup"
        zPosition = 22
        physicsBody = SKPhysicsBody(circleOfRadius: 14)
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = PhysicsCategory.powerUp
        physicsBody?.contactTestBitMask = PhysicsCategory.player
        physicsBody?.collisionBitMask = 0
    }
    required init?(coder: NSCoder) { fatalError() }
}
