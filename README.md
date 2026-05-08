# Strait Run

Strait Run is a fictionalized, arcade-style iOS action game built with SpriteKit (Swift).

## Features
- Start menu, gameplay, and game-over loop.
- 3-life system + optional second chance purchase for 100 points.
- Mines, missiles, shoreline instant-death boundaries.
- Combo multiplier scoring.
- Power-ups: Shield, Jet Engines, Rail Gun.
- Best score persistence with `UserDefaults`.
- Haptic feedback hooks.
- Launch screen and AppIcon asset placeholders included.

## Build requirements
- Xcode 15+
- iOS 16+
- Swift 5.9+

## Run in Xcode
1. Open `StraitOfHormuzShooter.xcodeproj`.
2. Select `StraitOfHormuzShooter` scheme.
3. Choose an iPhone simulator/device.
4. Press **Run**.

## Asset organization
- `Assets.xcassets/AppIcon.appiconset`: replace placeholders with production icon exports.
- `Assets.xcassets`: add sprites, particles, and audio files (`*.wav`) used by `AudioManager`.
- `Base.lproj/LaunchScreen.storyboard`: launch branding.

## App Store readiness checklist
- Add your Team + signing in target settings.
- Replace icon placeholders and add App Store marketing icon.
- Add privacy nutrition labels (no tracking/analytics required by default).
- Validate archive in Organizer, then upload to App Store Connect.
