import SpriteKit

/// Shown when the player runs out of lives.
class GameOverScene: SKScene {

    private let finalScore: Int

    // MARK: – Init
    init(size: CGSize, score: Int) {
        self.finalScore = score
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: – Scene lifecycle
    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 1)
        setupLabels()
        setupRestartButton()
    }

    // MARK: – Setup
    private func setupLabels() {
        // Title
        let title = SKLabelNode(fontNamed: "Courier-Bold")
        title.text = "GAME OVER"
        title.fontSize = 48
        title.fontColor = .systemRed
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.65)
        title.zPosition = 10
        addChild(title)

        // Subtitle
        let sub = SKLabelNode(fontNamed: "Courier")
        sub.text = "Strait of Hormuz"
        sub.fontSize = 18
        sub.fontColor = .systemTeal
        sub.position = CGPoint(x: size.width / 2, y: title.position.y - 44)
        sub.zPosition = 10
        addChild(sub)

        // Score
        let scoreLabel = SKLabelNode(fontNamed: "Courier-Bold")
        scoreLabel.text = "SCORE: \(finalScore)"
        scoreLabel.fontSize = 28
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.45)
        scoreLabel.zPosition = 10
        addChild(scoreLabel)
    }

    private func setupRestartButton() {
        let bg = SKShapeNode(rectOf: CGSize(width: 180, height: 50), cornerRadius: 12)
        bg.fillColor = .systemTeal
        bg.strokeColor = .white
        bg.lineWidth = 2
        bg.name = "restartButton"
        bg.position = CGPoint(x: size.width / 2, y: size.height * 0.30)
        bg.zPosition = 10
        addChild(bg)

        let label = SKLabelNode(fontNamed: "Courier-Bold")
        label.text = "PLAY AGAIN"
        label.fontSize = 20
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.name = "restartButton"
        label.zPosition = 11
        bg.addChild(label)
    }

    // MARK: – Touch handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tapped = nodes(at: location).compactMap { $0.name }
        if tapped.contains("restartButton") {
            restartGame()
        }
    }

    private func restartGame() {
        let scene = GameScene(size: size)
        scene.scaleMode = scaleMode
        view?.presentScene(scene, transition: .doorway(withDuration: 0.6))
    }
}
