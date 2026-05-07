import SpriteKit

/// A bullet fired by the player.
class Bullet: SKSpriteNode {

    // MARK: – Constants
    static let size  = CGSize(width: 8, height: 24)
    static let speed: CGFloat = 550

    // MARK: – Init
    init() {
        let texture = Bullet.makeTexture()
        super.init(texture: texture, color: .clear, size: Bullet.size)
        name = "bullet"
        zPosition = 9
        setupPhysics()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: – Physics
    private func setupPhysics() {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask    = PhysicsCategory.bullet
        physicsBody?.contactTestBitMask = PhysicsCategory.enemy
        physicsBody?.collisionBitMask   = PhysicsCategory.none
    }

    // MARK: – Launch action
    /// Returns an action that moves the bullet off the top of the scene.
    func launchAction(sceneHeight: CGFloat) -> SKAction {
        let distance = sceneHeight - position.y + Bullet.size.height
        let duration = TimeInterval(distance / Bullet.speed)
        let move = SKAction.moveBy(x: 0, y: distance, duration: duration)
        let remove = SKAction.removeFromParent()
        return SKAction.sequence([move, remove])
    }

    // MARK: – Texture
    private static func makeTexture() -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: Bullet.size)
        let image = renderer.image { ctx in
            let c = ctx.cgContext
            // Glow
            c.setFillColor(UIColor.systemYellow.withAlphaComponent(0.4).cgColor)
            c.fillEllipse(in: CGRect(x: 0, y: 0, width: 8, height: 24))
            // Core
            c.setFillColor(UIColor.white.cgColor)
            c.fillEllipse(in: CGRect(x: 2, y: 4, width: 4, height: 16))
        }
        return SKTexture(image: image)
    }
}
