import SpriteKit

/// Heads-up display showing score and remaining lives.
class HUD: SKNode {

    // MARK: – Child nodes
    private let scoreLabel  = SKLabelNode(fontNamed: "Courier-Bold")
    private let livesLabel  = SKLabelNode(fontNamed: "Courier-Bold")
    private let waveLabel   = SKLabelNode(fontNamed: "Courier-Bold")

    // MARK: – State
    private(set) var score: Int = 0
    private(set) var lives: Int = 3
    private(set) var wave:  Int = 1

    // MARK: – Init
    override init() {
        super.init()
        zPosition = 100
        setupLabels()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: – Layout
    func layout(in sceneSize: CGSize) {
        let top = sceneSize.height - 28
        scoreLabel.position = CGPoint(x: 12, y: top)
        livesLabel.position = CGPoint(x: sceneSize.width - 12, y: top)
        waveLabel.position  = CGPoint(x: sceneSize.width / 2, y: top)
    }

    private func setupLabels() {
        for label in [scoreLabel, livesLabel, waveLabel] {
            label.fontSize  = 18
            label.fontColor = .white
        }
        scoreLabel.horizontalAlignmentMode = .left
        livesLabel.horizontalAlignmentMode = .right
        waveLabel.horizontalAlignmentMode  = .center
        addChild(scoreLabel)
        addChild(livesLabel)
        addChild(waveLabel)
        refresh()
    }

    // MARK: – Mutations
    func addScore(_ points: Int) {
        score += points
        refresh()
    }

    func loseLife() -> Bool {
        lives -= 1
        refresh()
        return lives <= 0
    }

    func nextWave() {
        wave += 1
        refresh()
    }

    // MARK: – Rendering
    private func refresh() {
        scoreLabel.text = "SCORE: \(score)"
        livesLabel.text = "LIVES: \(lives)"
        waveLabel.text  = "WAVE \(wave)"
    }
}
