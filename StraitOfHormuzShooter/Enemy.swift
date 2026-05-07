import SpriteKit

/// An enemy ship that drifts downward and may fire back.
class Enemy: SKSpriteNode {

    // MARK: – Constants
    static let size = CGSize(width: 55, height: 70)

    enum EnemyType {
        case patrol   // straight down
        case zigzag   // side-to-side
        case fast     // faster speed
    }

    let type: EnemyType
    let speed: CGFloat
    var health: Int

    // MARK: – Init
    init(type: EnemyType = .patrol) {
        self.type = type
        switch type {
        case .patrol:  speed = 80;  health = 1
        case .zigzag:  speed = 60;  health = 2
        case .fast:    speed = 160; health = 1
        }
        let texture = Enemy.makeTexture(type: type)
        super.init(texture: texture, color: .clear, size: Enemy.size)
        name = "enemy"
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
        physicsBody?.categoryBitMask    = PhysicsCategory.enemy
        physicsBody?.contactTestBitMask = PhysicsCategory.bullet | PhysicsCategory.player
        physicsBody?.collisionBitMask   = PhysicsCategory.none
    }

    // MARK: – Movement action
    /// Returns an action that moves the enemy based on its type.
    func movementAction(sceneSize: CGSize) -> SKAction {
        switch type {
        case .patrol, .fast:
            let distance = sceneSize.height + Enemy.size.height
            let duration = TimeInterval(distance / speed)
            return SKAction.moveBy(x: 0, y: -distance, duration: duration)

        case .zigzag:
            let zigW: CGFloat = 80
            let stepH: CGFloat = 60
            let stepDur = TimeInterval(stepH / speed)
            let zig = SKAction.moveBy(x: zigW, y: -stepH, duration: stepDur)
            let zag = SKAction.moveBy(x: -zigW, y: -stepH, duration: stepDur)
            let pattern = SKAction.sequence([zig, zag])
            let stepsNeeded = Int((sceneSize.height + Enemy.size.height) / stepH) + 1
            return SKAction.repeat(pattern, count: stepsNeeded)
        }
    }

    // MARK: – Texture
    private static func makeTexture(type: EnemyType) -> SKTexture {
        let size = Enemy.size
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let c = ctx.cgContext
            let color: UIColor
            switch type {
            case .patrol: color = .systemRed
            case .zigzag: color = .systemOrange
            case .fast:   color = .systemPurple
            }
            c.setFillColor(color.cgColor)
            let hull = CGPath(roundedRect: CGRect(x: 8, y: 0, width: 39, height: 65),
                              cornerWidth: 6, cornerHeight: 6, transform: nil)
            c.addPath(hull)
            c.fillPath()
            // Cockpit
            c.setFillColor(UIColor.black.withAlphaComponent(0.5).cgColor)
            c.fillEllipse(in: CGRect(x: 17, y: 30, width: 21, height: 20))
            // Left wing
            c.setFillColor(color.withAlphaComponent(0.7).cgColor)
            let lw = CGMutablePath()
            lw.move(to: CGPoint(x: 8, y: 20))
            lw.addLine(to: CGPoint(x: 0, y: 45))
            lw.addLine(to: CGPoint(x: 8, y: 38))
            lw.closeSubpath()
            c.addPath(lw)
            c.fillPath()
            // Right wing
            let rw = CGMutablePath()
            rw.move(to: CGPoint(x: 47, y: 20))
            rw.addLine(to: CGPoint(x: 55, y: 45))
            rw.addLine(to: CGPoint(x: 47, y: 38))
            rw.closeSubpath()
            c.addPath(rw)
            c.fillPath()
        }
        return SKTexture(image: image)
    }
}
