import XCTest
@testable import StraitOfHormuzShooter

final class StraitOfHormuzShooterTests: XCTestCase {

    // MARK: – HUD tests

    func testHUDInitialState() {
        let hud = HUD()
        XCTAssertEqual(hud.score, 0)
        XCTAssertEqual(hud.lives, 3)
        XCTAssertEqual(hud.wave,  1)
    }

    func testHUDAddScore() {
        let hud = HUD()
        hud.addScore(10)
        XCTAssertEqual(hud.score, 10)
        hud.addScore(25)
        XCTAssertEqual(hud.score, 35)
    }

    func testHUDLoseLife_notGameOver() {
        let hud = HUD()
        let gameOver = hud.loseLife()
        XCTAssertFalse(gameOver)
        XCTAssertEqual(hud.lives, 2)
    }

    func testHUDLoseAllLives_gameOver() {
        let hud = HUD()
        _ = hud.loseLife()
        _ = hud.loseLife()
        let gameOver = hud.loseLife()
        XCTAssertTrue(gameOver)
        XCTAssertEqual(hud.lives, 0)
    }

    func testHUDNextWave() {
        let hud = HUD()
        hud.nextWave()
        XCTAssertEqual(hud.wave, 2)
    }

    // MARK: – Physics category tests

    func testPhysicsCategoriesAreUnique() {
        let categories: [UInt32] = [
            PhysicsCategory.player,
            PhysicsCategory.enemy,
            PhysicsCategory.bullet,
            PhysicsCategory.border,
        ]
        let unique = Set(categories)
        XCTAssertEqual(unique.count, categories.count, "Physics categories must be unique bitmasks")
    }

    func testPhysicsCategoriesAreNonZero() {
        XCTAssertNotEqual(PhysicsCategory.player, PhysicsCategory.none)
        XCTAssertNotEqual(PhysicsCategory.enemy,  PhysicsCategory.none)
        XCTAssertNotEqual(PhysicsCategory.bullet, PhysicsCategory.none)
        XCTAssertNotEqual(PhysicsCategory.border, PhysicsCategory.none)
    }

    func testPhysicsCategoriesAreSingleBits() {
        let categories: [UInt32] = [
            PhysicsCategory.player,
            PhysicsCategory.enemy,
            PhysicsCategory.bullet,
            PhysicsCategory.border,
        ]
        for cat in categories {
            XCTAssertTrue(cat != 0 && (cat & (cat - 1)) == 0,
                          "Category \(cat) is not a power-of-two bitmask")
        }
    }
}
