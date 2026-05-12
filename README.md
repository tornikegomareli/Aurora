# Aurora

A SwiftUI component that draws an Apple-Intelligence-style glowing ring
around any view. One Metal shader, no images, no GIFs — anchored
metaballs in four colours with a wavy edge that "carves" against the
black interior, plus a damped-cosine burst envelope on intro.

```swift
Card()
  .padding()
  .glow(.standard, cornerRadius: 24)
```

That's it.

## Install

Add Aurora to your `Package.swift`:

```swift
.package(url: "https://github.com/your-org/Aurora.git", from: "0.1.0")
```

Or in Xcode: **File → Add Package Dependencies…** and paste the URL.

Then `import Aurora`.

**Requirements**: iOS 17+. The shader uses
`ShaderLibrary` / `colorEffect` which is iOS 17 only.

## Quick start

Wrap any view in a glowing ring:

```swift
import Aurora
import SwiftUI

struct ContentView: View {
  var body: some View {
    RoundedRectangle(cornerRadius: 24, style: .continuous)
      .fill(.black)
      .frame(height: 120)
      .glow(.standard, cornerRadius: 24)
  }
}
```

## Styles

Three pre-tuned looks pick the burst feel:

| Style       | Feel                                                |
| ----------- | --------------------------------------------------- |
| `.subtle`   | gentle steady-state, soft intro, minimal flames     |
| `.standard` | recommended default; moderate burst                 |
| `.dramatic` | energetic intro, big flames; closest to Apple's     |

## Intro animation

By default, the glow plays a short intro on first appear: the band
grows in thickness from invisible to its target size in about 0.7
seconds, with the burst envelope (color churn + brightness pop)
running on top. That combination mimics the Apple Intelligence
long-press intro — a luminous frame that *grows* into existence
rather than fading in.

Disable it with the builder:

```swift
AuroraGlow(.standard).introOnAppear(false)
```

`introOnAppear` and `burstsOnAppear` are independent — you can keep
the burst pop without the thickness growth, or vice-versa.

## Fine-tuning

For more control, build an `AuroraGlow` directly and chain modifiers:

```swift
AuroraGlow(.dramatic)
  .cornerRadius(24)
  .borderWidth(4)
  .glowSize(18)
  .speed(0.2)
  .ignoresSafeArea()
```

Every modifier returns a new `AuroraGlow`, just like SwiftUI's built-in
modifiers.

You can pass a pre-configured glow to `.glow(_:)`:

```swift
Card().glow(
  AuroraGlow(.dramatic)
    .cornerRadius(24)
    .borderWidth(8)
)
```

If none of the presets fits, build a `Profile` by hand:

```swift
let custom = AuroraGlow.Profile(
  anchorAmpBoost: 0.5,
  anchorSpeedBoost: 2.5,
  flameAmpBoost: 3.0,
  brightnessPop: 0.4,
  decayRate: 1.5,
  flameBaseline: 0.5
)
AuroraGlow(profile: custom)
```

## Re-firing the burst

The intro animation runs once on appear. To re-fire it later (after a
network response lands, when a tab is selected, on a button tap, etc.),
hold a `Burster` and pass it in:

```swift
struct AssistantView: View {
  @State private var burster = AuroraGlow.Burster()

  var body: some View {
    VStack {
      ChatTranscript()
      Button("Ask again") { burster.fire() }
    }
    .glow(AuroraGlow(.standard).burster(burster))
  }
}
```

`Burster` is an `@Observable`, `@MainActor`-isolated reference type —
the view subscribes to its `lastFiredAt` and re-runs the burst envelope
whenever you call `fire()`. From off-main contexts (TCA effects,
detached tasks, NotificationCenter handlers) hop to the main actor
first:

```swift
Task { @MainActor in burster.fire() }
```

## Live tuning

`AuroraExamples` ships with `AuroraDemoView`, a sandbox screen with
sliders for every knob and a button to re-fire the burst. Use it in
Xcode previews while you dial in your design:

```swift
import AuroraExamples

#Preview {
  AuroraDemoView()
}
```

## Credits

The visual feel is reverse-engineered from Apple's `IntelligentLightFrag`
shader in `SiriUICore.framework`. None of Apple's binary code is
included — only the algorithm (anchored metaballs + warped SDF + noise
+ damped-cosine burst envelope) is reproduced.

## License

MIT.
