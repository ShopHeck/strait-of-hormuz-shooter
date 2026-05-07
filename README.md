# Strait of Hormuz Shooter

A top-down 2D iOS shooter game built with SpriteKit.  Guide your warship through the Strait of Hormuz, destroying enemy vessels wave after wave.

---

## Requirements

| Tool  | Version |
|-------|---------|
| Xcode | 15+     |
| iOS   | 16+     |
| Swift | 5.9+    |

---

## Project structure

```
StraitOfHormuzShooter.xcodeproj/   ← Xcode project
StraitOfHormuzShooter/
├── AppDelegate.swift              ← App entry point
├── GameViewController.swift       ← Hosts the SKView
├── PhysicsCategories.swift        ← Collision bitmasks
├── Player.swift                   ← Player ship node
├── Enemy.swift                    ← Enemy ship node (patrol / zigzag / fast)
├── Bullet.swift                   ← Player missile node
├── HUD.swift                      ← Score, lives & wave overlay
├── GameScene.swift                ← Main gameplay scene
├── GameOverScene.swift            ← Game-over screen with replay button
├── Assets.xcassets/               ← App icon & accent color
└── Base.lproj/
    ├── Main.storyboard            ← Wires GameViewController → SKView
    └── LaunchScreen.storyboard    ← Launch screen
StraitOfHormuzShooterTests/
└── StraitOfHormuzShooterTests.swift  ← Unit tests (HUD, physics categories)
```

---

## How to build & run

1. Open `StraitOfHormuzShooter.xcodeproj` in Xcode.
2. Select an iPhone simulator or a real device (iOS 16+).
3. Press **⌘R** (Product → Run).

## How to test

Press **⌘U** (Product → Test) or run from the command line:

```bash
xcodebuild test \
  -project StraitOfHormuzShooter.xcodeproj \
  -scheme StraitOfHormuzShooter \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

---

## Gameplay

| Control | Action |
|---------|--------|
| Tap & drag | Move your ship left/right |
| (automatic) | Your ship fires continuously |

- Destroy enemy ships to score points.
- Each wave gets faster and more frequent.
- You have **3 lives** — an enemy reaching the bottom costs one life.
- Three enemy types: **Patrol** (straight), **Zigzag**, and **Fast**.

---

## Architecture

The game uses Apple's **SpriteKit** framework and follows a scene-based architecture:

```
GameViewController  →  GameScene  (gameplay)
                    →  GameOverScene  (score + restart)
```

Physics collision detection is handled by `SKPhysicsContactDelegate` with dedicated bitmask categories in `PhysicsCategories.swift`.
