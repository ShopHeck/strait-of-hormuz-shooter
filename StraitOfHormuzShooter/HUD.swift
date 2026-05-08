import SpriteKit

final class HUD: SKNode {
    let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    let livesLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    let comboLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    let powerLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")

    func setup(size: CGSize) {
        [scoreLabel,livesLabel,comboLabel,powerLabel].forEach { l in
            l.fontSize = 18; l.horizontalAlignmentMode = .left; l.zPosition = 200; addChild(l)
        }
        scoreLabel.position = CGPoint(x: 18, y: size.height - 40)
        livesLabel.position = CGPoint(x: 18, y: size.height - 64)
        comboLabel.position = CGPoint(x: 18, y: size.height - 88)
        powerLabel.position = CGPoint(x: 18, y: size.height - 112)
    }

    func refresh(score: Int, lives: Int, combo: Int, activePower: String?) {
        scoreLabel.text = "Score: \(score)"
        livesLabel.text = "Lives: \(lives)"
        comboLabel.text = "Combo: x\(combo)"
        powerLabel.text = activePower.map { "Power: \($0)" } ?? "Power: None"
    }
}
