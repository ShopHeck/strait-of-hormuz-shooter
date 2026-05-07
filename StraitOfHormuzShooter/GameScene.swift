import SpriteKit
import GameplayKit

/// Primary gameplay scene — ocean-crossing shooter in the Strait of Hormuz.
class GameScene: SKScene {

    // MARK: – Child nodes
    private var player: Player!
    private var hud: HUD!
    private var ocean: SKSpriteNode!

    // MARK: – State
    private var lastUpdateTime: TimeInterval = 0
    private var lastFireTime:   TimeInterval = 0
    private var lastEnemySpawn: TimeInterval = 0
    private var touchLocation:  CGPoint?

    private let fireInterval:  TimeInterval = 0.35
    private var spawnInterval: TimeInterval = 1.6
    private var enemiesRemaining = 0
    private let enemiesPerWave   = 8

    /// Minimum allowed spawn interval so enemies never arrive impossibly fast.
    private let minSpawnInterval: TimeInterval = 0.6
    /// Amount by which the spawn interval shrinks each wave.
    private let spawnIntervalDecrement: TimeInterval = 0.05

    // Enemy type spawn thresholds (cumulative, out of 10)
    private let zigzagThreshold = 5   // rolls 0–4  → patrol (50 %)
    private let fastThreshold   = 8   // rolls 5–7  → zigzag (30 %); 8–9 → fast (20 %)

    // MARK: – Scene lifecycle
    override func didMove(to view: SKView) {
        physicsWorld.gravity     = .zero
        physicsWorld.contactDelegate = self

        setupOcean()
        setupBorder()
        setupPlayer()
        setupHUD()
        spawnWave()
    }

    // MARK: – Setup
    private func setupOcean() {
        ocean = SKSpriteNode(color: .init(red: 0.05, green: 0.25, blue: 0.50, alpha: 1), size: size)
        ocean.position = CGPoint(x: size.width / 2, y: size.height / 2)
        ocean.zPosition = 0
        addChild(ocean)

        // Scrolling wave stripes
        for i in 0..<10 {
            let stripe = SKSpriteNode(
                color: UIColor.white.withAlphaComponent(CGFloat.random(in: 0.03...0.09)),
                size: CGSize(width: size.width, height: CGFloat.random(in: 3...10))
            )
            stripe.position = CGPoint(x: size.width / 2, y: CGFloat(i) * (size.height / 9))
            stripe.zPosition = 1
            addChild(stripe)

            let scroll = SKAction.sequence([
                SKAction.moveBy(x: 0, y: -size.height, duration: TimeInterval.random(in: 6...14)),
                SKAction.moveBy(x: 0, y: size.height, duration: 0)
            ])
            stripe.run(SKAction.repeatForever(scroll))
        }
    }

    private func setupBorder() {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody?.categoryBitMask = PhysicsCategory.border
    }

    private func setupPlayer() {
        player = Player()
        player.position = CGPoint(x: size.width / 2, y: 80)
        addChild(player)
    }

    private func setupHUD() {
        hud = HUD()
        hud.layout(in: size)
        addChild(hud)
    }

    // MARK: – Wave spawning
    private func spawnWave() {
        enemiesRemaining = enemiesPerWave
        spawnInterval = max(minSpawnInterval, spawnInterval - spawnIntervalDecrement * Double(hud.wave - 1))
    }

    private func spawnEnemy() {
        guard enemiesRemaining > 0 else { return }
        enemiesRemaining -= 1

        let typeRoll = Int.random(in: 0..<10)
        let type: Enemy.EnemyType = typeRoll < zigzagThreshold ? .patrol : (typeRoll < fastThreshold ? .zigzag : .fast)
        let enemy = Enemy(type: type)

        let margin = Enemy.size.width / 2
        let x = CGFloat.random(in: margin...(size.width - margin))
        enemy.position = CGPoint(x: x, y: size.height + Enemy.size.height / 2)
        addChild(enemy)

        let move   = enemy.movementAction(sceneSize: size)
        let remove = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([move, remove])) { [weak self] in
            // Enemy passed through — player loses a life
            self?.playerHit()
        }
    }

    // MARK: – Firing
    private func fireBullet() {
        let bullet = Bullet()
        bullet.position = CGPoint(x: player.position.x, y: player.position.y + Player.size.height / 2)
        addChild(bullet)
        bullet.run(bullet.launchAction(sceneHeight: size.height))

        // Muzzle flash
        let flash = SKSpriteNode(color: .systemYellow, size: CGSize(width: 10, height: 10))
        flash.position = bullet.position
        flash.zPosition = 20
        addChild(flash)
        flash.run(SKAction.sequence([.fadeOut(withDuration: 0.08), .removeFromParent()]))
    }

    // MARK: – Game events
    private func playerHit() {
        guard let body = player.physicsBody, body.isDynamic else { return }
        let gameOver = hud.loseLife()
        flashScreen(color: .red)
        if gameOver { endGame() }
    }

    private func bulletHitEnemy(_ bullet: SKSpriteNode, enemy: Enemy) {
        bullet.removeFromParent()

        enemy.health -= 1
        if enemy.health <= 0 {
            explode(at: enemy.position)
            enemy.removeFromParent()
            hud.addScore(pointValue(for: enemy.type))

            if enemiesRemaining == 0 && !children.contains(where: { $0.name == "enemy" }) {
                hud.nextWave()
                run(SKAction.wait(forDuration: 1.2)) { [weak self] in
                    self?.spawnWave()
                }
            }
        } else {
            // Flash enemy
            let flash = SKAction.sequence([
                .colorize(with: .white, colorBlendFactor: 1, duration: 0.05),
                .colorize(withColorBlendFactor: 0, duration: 0.1)
            ])
            enemy.run(flash)
        }
    }

    private func pointValue(for type: Enemy.EnemyType) -> Int {
        switch type {
        case .patrol: return 10
        case .zigzag: return 20
        case .fast:   return 15
        }
    }

    private func endGame() {
        let gameOver = GameOverScene(size: size, score: hud.score)
        gameOver.scaleMode = scaleMode
        view?.presentScene(gameOver, transition: .fade(withDuration: 0.8))
    }

    // MARK: – Visual effects
    private func explode(at position: CGPoint) {
        let emitter = SKEmitterNode()
        emitter.particleBirthRate       = 80
        emitter.numParticlesToEmit      = 40
        emitter.particleLifetime        = 0.6
        emitter.particleLifetimeRange   = 0.3
        emitter.particleSpeed           = 100
        emitter.particleSpeedRange      = 80
        emitter.emissionAngleRange      = .pi * 2
        emitter.particleAlpha           = 1
        emitter.particleAlphaRange      = 0.3
        emitter.particleAlphaSpeed      = -1.5
        emitter.particleScale           = 0.15
        emitter.particleScaleRange      = 0.1
        emitter.particleScaleSpeed      = -0.2
        emitter.particleColor           = .systemOrange
        emitter.particleColorBlendFactor = 1
        emitter.position = position
        emitter.zPosition = 20
        addChild(emitter)
        emitter.run(SKAction.sequence([.wait(forDuration: 1.0), .removeFromParent()]))
    }

    private func flashScreen(color: UIColor) {
        let flash = SKSpriteNode(color: color.withAlphaComponent(0.4), size: size)
        flash.position = CGPoint(x: size.width / 2, y: size.height / 2)
        flash.zPosition = 50
        addChild(flash)
        flash.run(SKAction.sequence([.fadeOut(withDuration: 0.3), .removeFromParent()]))
    }

    // MARK: – Touch handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchLocation = touches.first?.location(in: self)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchLocation = touches.first?.location(in: self)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchLocation = nil
    }

    // MARK: – Update loop
    override func update(_ currentTime: TimeInterval) {
        let dt = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // Move player toward touch
        if let target = touchLocation {
            player.move(toX: target.x, sceneWidth: size.width, dt: dt)
        }

        // Auto-fire
        if currentTime - lastFireTime >= fireInterval {
            fireBullet()
            lastFireTime = currentTime
        }

        // Spawn enemies
        if currentTime - lastEnemySpawn >= spawnInterval {
            spawnEnemy()
            lastEnemySpawn = currentTime
        }
    }
}

// MARK: – SKPhysicsContactDelegate
extension GameScene: SKPhysicsContactDelegate {

    func didBegin(_ contact: SKPhysicsContact) {
        let (a, b) = (contact.bodyA.node, contact.bodyB.node)

        if let bullet = a as? Bullet, let enemy = b as? Enemy {
            bulletHitEnemy(bullet, enemy: enemy)
        } else if let bullet = b as? Bullet, let enemy = a as? Enemy {
            bulletHitEnemy(bullet, enemy: enemy)
        } else if a?.name == "player" || b?.name == "player" {
            playerHit()
        }
    }
}
