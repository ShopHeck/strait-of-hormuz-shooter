import SpriteKit
import UIKit

final class GameScene: SKScene, SKPhysicsContactDelegate {
    private let player = Player()
    private let hud = HUD()
    private var score = 0
    private var bestScore: Int { UserDefaults.standard.integer(forKey: "bestScore") }
    private var lives = 3
    private var combo = 1
    private var lastDamageTime: TimeInterval = 0
    private var isPausedByMenu = false
    private var scrollSpeed: CGFloat = 140
    private var lastUpdate: TimeInterval = 0
    private var lastFire: TimeInterval = 0
    private var lastMine: TimeInterval = 0
    private var lastMissile: TimeInterval = 0
    private var mineInterval: TimeInterval = 1.2
    private var missileInterval: TimeInterval = 2.0
    private var touchAnchor: CGPoint?
    private var secondChanceUsed = false

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.03, green: 0.22, blue: 0.45, alpha: 1)
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        setupLand()
        player.position = CGPoint(x: size.width/2, y: size.height*0.2)
        addChild(player)
        hud.setup(size: size); addChild(hud)
        refreshHUD(now: 0)
    }

    private func setupLand() {
        for side in [0,1] {
            let land = SKSpriteNode(color: .brown, size: CGSize(width: size.width * 0.18, height: size.height*2))
            land.position = CGPoint(x: side == 0 ? land.size.width/2 : size.width-land.size.width/2, y: size.height/2)
            land.name = "land"
            land.zPosition = 5
            land.physicsBody = SKPhysicsBody(rectangleOf: land.size)
            land.physicsBody?.isDynamic = false
            land.physicsBody?.categoryBitMask = PhysicsCategory.land
            land.physicsBody?.contactTestBitMask = PhysicsCategory.player
            addChild(land)
        }
    }

    override func update(_ currentTime: TimeInterval) {
        let dt = lastUpdate == 0 ? 0 : currentTime - lastUpdate
        lastUpdate = currentTime
        if isPausedByMenu { return }
        scrollSpeed += CGFloat(dt) * 1.5
        mineInterval = max(0.45, mineInterval - dt * 0.002)
        missileInterval = max(0.8, missileInterval - dt * 0.002)

        if let a = touchAnchor {
            let targetX = min(max(a.x, size.width * 0.2), size.width * 0.8)
            player.position.x += (targetX - player.position.x) * min(1, CGFloat(dt) * 9)
        }

        if currentTime - lastMine > mineInterval { spawnMine(); lastMine = currentTime }
        if currentTime - lastMissile > missileInterval { spawnMissile(); lastMissile = currentTime }
        if currentTime - lastFire > 0.22 { fire(); lastFire = currentTime }

        enumerateChildNodes(withName: "mine") { n,_ in n.position.y -= self.scrollSpeed * CGFloat(dt); if n.position.y < -40 { n.removeFromParent() } }
        enumerateChildNodes(withName: "missile") { n,_ in n.position.y -= (self.scrollSpeed+80) * CGFloat(dt); if n.position.y < -40 { n.removeFromParent() } }
        enumerateChildNodes(withName: "powerup") { n,_ in n.position.y -= self.scrollSpeed * CGFloat(dt); n.alpha -= 0.001; if n.position.y < -20 || n.alpha < 0.2 { n.removeFromParent() } }

        refreshHUD(now: currentTime)
    }

    private func spawnMine() { let m = Mine(); m.position = CGPoint(x: .random(in: size.width*0.22...size.width*0.78), y: size.height+30); addChild(m) }
    private func spawnMissile() { let m = Missile(); m.position = CGPoint(x: .random(in: size.width*0.22...size.width*0.78), y: size.height+50); addChild(m) }
    private func fire() {
        if player.isRail(lastUpdate) {
            let beam = SKSpriteNode(color: .systemRed, size: CGSize(width: 8, height: size.height))
            beam.position = CGPoint(x: player.position.x, y: size.height/2)
            beam.alpha = 0.5; beam.zPosition = 27; beam.name = "rail"
            addChild(beam)
            beam.run(.sequence([.wait(forDuration: 0.08), .removeFromParent()]))
            enumerateChildNodes(withName: "mine") { n,_ in if abs(n.position.x - self.player.position.x) < 24 { self.destroyTarget(n,isMissile:false)} }
            enumerateChildNodes(withName: "missile") { n,_ in if abs(n.position.x - self.player.position.x) < 24 { self.destroyTarget(n,isMissile:true)} }
        } else {
            let b = Bullet(); b.position = CGPoint(x: player.position.x, y: player.position.y + 60); addChild(b)
            b.run(.sequence([.moveBy(x: 0, y: size.height, duration: 0.7), .removeFromParent()]))
        }
    }

    private func destroyTarget(_ node: SKNode, isMissile: Bool) {
        node.removeFromParent(); score += (isMissile ? 20 : 12) * combo; combo += 1
        if Int.random(in: 0..<100) < 20 { spawnPowerUp(at: node.position) }
    }
    private func spawnPowerUp(at p: CGPoint) { let t = PowerUpType.allCases.randomElement()!; let n = PowerUpNode(type: t); n.position = p; addChild(n) }
    private func takeDamage() {
        if player.isInvincible(lastUpdate) { return }
        lives -= 1; combo = 1; lastDamageTime = lastUpdate; UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        if lives <= 0 { gameOver() }
    }
    private func gameOver() {
        isPausedByMenu = true
        let canSecondChance = !secondChanceUsed && score >= 100
        UserDefaults.standard.set(max(score, bestScore), forKey: "bestScore")
        let over = GameOverScene(size: size, score: score, best: max(score,bestScore), canSecondChance: canSecondChance) { [weak self] useSecond in
            guard let self else { return }
            if useSecond && canSecondChance {
                self.secondChanceUsed = true; self.score -= 100; self.lives = 1; self.isPausedByMenu = false
            } else {
                self.view?.presentScene(GameScene(size: self.size), transition: .crossFade(withDuration: 0.4))
            }
        }
        view?.presentScene(over, transition: .fade(withDuration: 0.3))
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let bodies = [contact.bodyA, contact.bodyB]
        if bodies.contains(where: {$0.categoryBitMask == PhysicsCategory.land}) && bodies.contains(where: {$0.categoryBitMask == PhysicsCategory.player}) { gameOver(); return }
        if let p = bodies.first(where: {$0.categoryBitMask == PhysicsCategory.player}), let power = bodies.first(where: {$0.categoryBitMask == PhysicsCategory.powerUp})?.node as? PowerUpNode {
            apply(power.type); power.removeFromParent(); UINotificationFeedbackGenerator().notificationOccurred(.success); _ = p
        }
        if let bullet = bodies.first(where: {$0.categoryBitMask == PhysicsCategory.projectile})?.node,
           let target = bodies.first(where: {$0.categoryBitMask == PhysicsCategory.mine || $0.categoryBitMask == PhysicsCategory.missile})?.node {
            destroyTarget(target, isMissile: target.name == "missile"); bullet.removeFromParent()
        }
        if bodies.contains(where: {$0.categoryBitMask == PhysicsCategory.player}) && bodies.contains(where: {$0.categoryBitMask == PhysicsCategory.mine || $0.categoryBitMask == PhysicsCategory.missile}) { takeDamage() }
    }

    private func apply(_ t: PowerUpType) {
        switch t {
        case .shield: player.invincibleUntil = lastUpdate + 10
        case .jet: player.jetUntil = lastUpdate + 10; scrollSpeed *= 1.2
        case .rail: player.railUntil = lastUpdate + 10
        }
    }
    private func refreshHUD(now: TimeInterval) {
        var ap: String? = nil
        if player.isInvincible(now) { ap = "Shield \(Int(player.invincibleUntil-now))s" }
        else if player.isJet(now) { ap = "Jets \(Int(player.jetUntil-now))s" }
        else if player.isRail(now) { ap = "Rail \(Int(player.railUntil-now))s" }
        hud.refresh(score: score, lives: lives, combo: combo, activePower: ap)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { touchAnchor = touches.first?.location(in: self) }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) { touchAnchor = touches.first?.location(in: self) }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) { touchAnchor = nil }
}
