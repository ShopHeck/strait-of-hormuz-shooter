import SpriteKit

final class MenuScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = .black
        let title = SKLabelNode(text: "Strait Run")
        title.fontName = "AvenirNext-Bold"; title.fontSize = 46; title.position = CGPoint(x: size.width/2, y: size.height*0.64)
        addChild(title)
        let info = SKLabelNode(text: "Drag to steer • Auto fire • Avoid shoreline")
        info.fontName = "AvenirNext-Medium"; info.fontSize = 18; info.position = CGPoint(x: size.width/2, y: size.height*0.56)
        addChild(info)
        let play = SKLabelNode(text: "Tap to Play")
        play.name = "play"; play.fontName = "AvenirNext-Bold"; play.fontSize = 30; play.position = CGPoint(x: size.width/2, y: size.height*0.42)
        addChild(play)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view?.presentScene(GameScene(size: size), transition: .doorsOpenVertical(withDuration: 0.5))
    }
}

final class GameOverScene: SKScene {
    private let score: Int
    private let best: Int
    private let canSecond: Bool
    private let completion: (Bool) -> Void
    init(size: CGSize, score: Int, best: Int, canSecondChance: Bool, completion: @escaping (Bool)->Void) {
        self.score = score; self.best = best; self.canSecond = canSecondChance; self.completion = completion
        super.init(size: size)
    }
    required init?(coder: NSCoder) { fatalError() }
    override func didMove(to view: SKView) {
        backgroundColor = .darkGray
        let t = SKLabelNode(text: "Game Over")
        t.fontSize = 42; t.position = CGPoint(x: size.width/2, y: size.height*0.68); addChild(t)
        let s = SKLabelNode(text: "Score: \(score)   Best: \(best)")
        s.fontSize = 24; s.position = CGPoint(x: size.width/2, y: size.height*0.58); addChild(s)
        let restart = SKLabelNode(text: "Restart")
        restart.name = "restart"; restart.position = CGPoint(x: size.width/2, y: size.height*0.44); addChild(restart)
        let menu = SKLabelNode(text: "Main Menu")
        menu.name = "menu"; menu.position = CGPoint(x: size.width/2, y: size.height*0.36); addChild(menu)
        if canSecond { let c = SKLabelNode(text: "Second Chance (-100)"); c.name = "second"; c.position = CGPoint(x: size.width/2, y: size.height*0.50); addChild(c)}
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let p = touches.first?.location(in: self), let n = nodes(at: p).first?.name else { return }
        if n == "second" { completion(true) }
        else if n == "menu" { view?.presentScene(MenuScene(size: size), transition: .fade(withDuration: 0.3)) }
        else { completion(false) }
    }
}
