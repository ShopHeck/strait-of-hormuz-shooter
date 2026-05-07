import SpriteKit

/// The player-controlled ship node.
class Player: SKSpriteNode {

    // MARK: – Constants
    static let size = CGSize(width: 60, height: 80)
    private let moveSpeed: CGFloat = 350

    // MARK: – Init
    init() {
        let texture = Player.makeTexture()
        super.init(texture: texture, color: .clear, size: Player.size)
        name = "player"
        zPosition = 10
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
        physicsBody?.allowsRotation = false
        physicsBody?.categoryBitMask    = PhysicsCategory.player
        physicsBody?.contactTestBitMask = PhysicsCategory.enemy
        physicsBody?.collisionBitMask   = PhysicsCategory.border
    }

    // MARK: – Movement
    /// Move the player toward `targetX`, clamped to `sceneWidth`.
    func move(toX targetX: CGFloat, sceneWidth: CGFloat, dt: TimeInterval) {
        let halfW = size.width / 2
        let clampedX = min(max(targetX, halfW), sceneWidth - halfW)
        let delta = clampedX - position.x
        let step = moveSpeed * CGFloat(dt)
        if abs(delta) <= step {
            position.x = clampedX
        } else {
            position.x += delta < 0 ? -step : step
        }
    }

    // MARK: – Texture
    private static func makeTexture() -> SKTexture {
        let size = Player.size
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let c = ctx.cgContext
            // Ship hull
            c.setFillColor(UIColor.systemTeal.cgColor)
            let hull = CGPath(roundedRect: CGRect(x: 10, y: 0, width: 40, height: 70),
                              cornerWidth: 8, cornerHeight: 8, transform: nil)
            c.addPath(hull)
            c.fillPath()
            // Cockpit
            c.setFillColor(UIColor.systemBlue.withAlphaComponent(0.8).cgColor)
            c.fillEllipse(in: CGRect(x: 20, y: 15, width: 20, height: 25))
            // Left wing
            c.setFillColor(UIColor.systemGreen.cgColor)
            let lWing = CGMutablePath()
            lWing.move(to: CGPoint(x: 10, y: 40))
            lWing.addLine(to: CGPoint(x: 0, y: 65))
            lWing.addLine(to: CGPoint(x: 10, y: 60))
            lWing.closeSubpath()
            c.addPath(lWing)
            c.fillPath()
            // Right wing
            let rWing = CGMutablePath()
            rWing.move(to: CGPoint(x: 50, y: 40))
            rWing.addLine(to: CGPoint(x: 60, y: 65))
            rWing.addLine(to: CGPoint(x: 50, y: 60))
            rWing.closeSubpath()
            c.addPath(rWing)
            c.fillPath()
        }
        return SKTexture(image: image)
    }
}
