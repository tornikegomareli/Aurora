# Aurora

Apple-Intelligence-style glow for SwiftUI, simple as that.

## Overview

Aurora is a native SwiftUI component that draws an animated colourful ring around any view. One Metal fragment shader, no images, no GIFs — anchored metaballs with a wave-warped edge and a damped-cosine burst envelope on appear.

<p align="center">
  <img src="https://img.shields.io/badge/Swift-5.9+-orange.svg" />
  <img src="https://img.shields.io/badge/iOS-17.0+-blue.svg" />
  <img src="https://img.shields.io/badge/SwiftUI-Native-green.svg" />
</p>

## Showcase

<p align="center">
  <img src="https://github.com/tornikegomareli/Aurora/releases/download/0.3.0/demo11.gif" width="30%" />
  <img src="https://github.com/tornikegomareli/Aurora/releases/download/0.3.0/demo22.gif" width="30%" />
  <img src="https://github.com/tornikegomareli/Aurora/releases/download/0.3.0/demo33.gif" width="30%" />
</p>
<p align="center">
  <img src="https://github.com/user-attachments/assets/PLACEHOLDER-AURORA-GIF-4" width="40%" />
  <img src="https://github.com/user-attachments/assets/PLACEHOLDER-AURORA-GIF-5" width="40%" />
</p>

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/tornikegomareli/Aurora.git", from: "0.3.0")
]
```

Or via Xcode: **File → Add Package Dependencies**

## Quick Start

```swift
import SwiftUI
import Aurora

struct ContentView: View {
    var body: some View {
        Card()
            .padding()
            .glow(.standard, cornerRadius: 24)
    }
}
```

That's it. The glow plays an intro on appear and settles into a gentle steady-state.

## Styles

Three presets pick the overall feel:

| Style       | Feel                                            |
|-------------|-------------------------------------------------|
| `.subtle`   | gentle steady-state, soft intro                 |
| `.standard` | recommended default; moderate burst             |
| `.dramatic` | energetic intro, big flames; closest to Apple's |

```swift
AuroraGlow(.dramatic).ignoresSafeArea()
```

## Palettes

Six built-in palettes:

```swift
AuroraGlow(.standard).palette(.appleIntelligence)  // default
AuroraGlow(.standard).palette(.sunset)
AuroraGlow(.standard).palette(.ocean)
AuroraGlow(.standard).palette(.forest)
AuroraGlow(.standard).palette(.monochrome)
AuroraGlow(.standard).palette(.cyberpunk)
```

Or roll your own:

```swift
let brand = AuroraGlow.Palette(
    base: SIMD3(0.1, 0.2, 0.4),
    anchors: [
        SIMD3(1.0, 0.5, 0.0),
        SIMD3(0.5, 0.8, 0.3),
        SIMD3(0.2, 0.4, 0.9),
        SIMD3(1.0, 0.2, 0.7),
    ]
)
AuroraGlow(.standard).palette(brand)
```

## Intro animations

Three intro styles for how the glow appears:

| Style            | What you see                                            |
|------------------|---------------------------------------------------------|
| `.thicknessGrow` | Band scales from invisible to full thickness            |
| `.borderFill`    | Band draws itself around the perimeter from one edge    |
| `.heartbeat`     | Thickness pulses 2–3× before settling                   |

```swift
AuroraGlow(.standard)
    .introStyle(.borderFill)
    .introDuration(0.5)
    .direction(.topToBottom)
```

Four direction cases: `.leftToRight`, `.rightToLeft`, `.topToBottom`, `.bottomToTop`.

## Moods

Semantic presets that bundle a palette and a speed:

```swift
AuroraGlow(.standard).mood(.listening)   // appleIntelligence palette, faster pace
AuroraGlow(.standard).mood(.thinking)    // ocean palette, slower
AuroraGlow(.standard).mood(.error)       // red palette
AuroraGlow(.standard).mood(.success)     // green palette
```

## glowWhileLoading

For AI streaming and async work:

```swift
@State private var isLoading = false

ChatView()
    .glowWhileLoading(isLoading)
    .task {
        isLoading = true
        await streamFromAI()
        isLoading = false
    }
```

Intro plays on start, holds while loading, outro plays when done.

## Re-firing the burst

For manual triggers — button taps, TCA effects, anywhere outside the View:

```swift
@State private var burster = AuroraGlow.Burster()

Card().glow(AuroraGlow(.standard).burster(burster))

Button("Ask again") { burster.fire() }
```

`Burster` is `@MainActor`-isolated. From off-main contexts hop first: `Task { @MainActor in burster.fire() }`.

## Customization

Chain modifiers for full control:

```swift
AuroraGlow(.standard)
    .palette(.sunset)
    .direction(.rightToLeft)
    .introStyle(.heartbeat)
    .introDuration(0.7)
    .outroStyle(.dissolve)
    .cornerRadius(24)
    .borderWidth(6)
    .glowSize(28)
    .speed(0.12)
```

Every modifier returns a new `AuroraGlow`, just like SwiftUI built-ins.

## Examples

`AuroraExamples` (Xcode project under `Examples/AuroraExamples`) ships seven demo screens — hero, live tuning, custom profile, wash tuning, palette gallery, moods, and a `glowWhileLoading` sandbox. Open the project to play with them.

## Requirements

- iOS 17+
- Swift 5.9+
- The shader uses `ShaderLibrary` / `colorEffect`, which are iOS 17 only.

## Credits

The visual feel is reverse-engineered from Apple's `IntelligentLightFrag` shader in `SiriUICore.framework`. None of Apple's binary code is included — only the algorithm (anchored metaballs + noise-warped SDF + damped-cosine burst envelope) is reproduced.

## License

MIT.
