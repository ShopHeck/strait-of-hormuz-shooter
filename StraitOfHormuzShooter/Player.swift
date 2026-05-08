import SpriteKit

final class Player: SKSpriteNode {
    var invincibleUntil: TimeInterval = 0
    var jetUntil: TimeInterval = 0
    var railUntil: TimeInterval = 0

    init(size: CGSize = CGSize(width: 56, height: 96)) {
        super.init(texture: nil, color: .clear, size: size)
        name = "player"
        zPosition = 30
        draw()
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 42, height: 84))
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = PhysicsCategory.player
        physicsBody?.contactTestBitMask = PhysicsCategory.mine | PhysicsCategory.missile | PhysicsCategory.powerUp | PhysicsCategory.land
        physicsBody?.collisionBitMask = PhysicsCategory.none
    }

    required init?(coder: NSCoder) { fatalError() }

    private func draw() {
        let hull = SKShapeNode(rectOf: CGSize(width: 44, height: 86), cornerRadius: 8)
        hull.fillColor = .systemGray
        hull.strokeColor = .white
        addChild(hull)
        let deck = SKShapeNode(rectOf: CGSize(width: 30, height: 40), cornerRadius: 6)
        deck.fillColor = .systemBlue
        deck.position = CGPoint(x: 0, y: -8)
        addChild(deck)
    }

    func isInvincible(_ now: TimeInterval) -> Bool { now < invincibleUntil }
    func isJet(_ now: TimeInterval) -> Bool { now < jetUntil }
    func isRail(_ now: TimeInterval) -> Bool { now < railUntil }
}
