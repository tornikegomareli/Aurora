import SwiftUI

/// A text view whose glyphs are filled with the same animated metaball
/// colour field used by `AuroraGlow` — the "Apple Intelligence"
/// shimmering text look. Drop it in anywhere you'd use a `Text`:
///
///     AuroraText("Apple Intelligence")
///         .font(.system(size: 56, weight: .heavy, design: .rounded))
///         .palette(.appleIntelligence)
///
/// Reads `\.font`, `\.fontWeight`, `\.kerning`, `\.lineSpacing`, and
/// every other text-style environment value via the underlying `Text`.
public struct AuroraText: View {
  public var content: String
  public var palette: AuroraGlow.Palette = .appleIntelligence
  public var speed: Double = 0.12

  @State private var startDate = Date()
  @State private var size: CGSize = .zero

  public init(_ content: String) {
    self.content = content
  }

  public var body: some View {
    TimelineView(.animation) { context in
      let elapsed = context.date.timeIntervalSince(startDate) * speed
      Text(content)
        .foregroundStyle(shader(at: elapsed))
    }
    .background(
      GeometryReader { proxy in
        Color.clear.preference(
          key: AuroraTextSizeKey.self,
          value: proxy.size
        )
      }
    )
    .onPreferenceChange(AuroraTextSizeKey.self) { newSize in
      size = newSize
    }
    .accessibilityLabel(content)
  }

  private func shader(at time: Double) -> Shader {
    let w = max(size.width, 1)
    let h = max(size.height, 1)
    return ShaderLibrary.bundle(.module).auroraShimmer(
      .float2(w, h),
      .float(time),
      .float3(
        CGFloat(palette.base.x),
        CGFloat(palette.base.y),
        CGFloat(palette.base.z)
      ),
      .float3(
        CGFloat(palette.anchors[0].x),
        CGFloat(palette.anchors[0].y),
        CGFloat(palette.anchors[0].z)
      ),
      .float3(
        CGFloat(palette.anchors[1].x),
        CGFloat(palette.anchors[1].y),
        CGFloat(palette.anchors[1].z)
      ),
      .float3(
        CGFloat(palette.anchors[2].x),
        CGFloat(palette.anchors[2].y),
        CGFloat(palette.anchors[2].z)
      ),
      .float3(
        CGFloat(palette.anchors[3].x),
        CGFloat(palette.anchors[3].y),
        CGFloat(palette.anchors[3].z)
      )
    )
  }
}

extension AuroraText {
  public func palette(_ value: AuroraGlow.Palette) -> Self {
    with(\.palette, value)
  }

  public func speed(_ value: Double) -> Self {
    with(\.speed, value)
  }

  public func mood(_ value: AuroraGlow.Mood) -> Self {
    guard value != .neutral else { return self }
    var copy = self
    copy.palette = value.palette
    copy.speed = self.speed * value.speedMultiplier
    return copy
  }

  private func with<T>(_ keyPath: WritableKeyPath<Self, T>, _ value: T) -> Self {
    var copy = self
    copy[keyPath: keyPath] = value
    return copy
  }
}

private struct AuroraTextSizeKey: PreferenceKey {
  static let defaultValue: CGSize = .zero
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
    value = nextValue()
  }
}

#Preview("Hero") {
  ZStack {
    Color.black.ignoresSafeArea()
    AuroraText("Apple\nIntelligence")
      .font(.system(size: 56, weight: .heavy, design: .rounded))
      .multilineTextAlignment(.center)
  }
}

#Preview("Palettes") {
  ZStack {
    Color.black.ignoresSafeArea()
    VStack(spacing: 22) {
      AuroraText("Aurora")
        .palette(.appleIntelligence)
      AuroraText("Sunset")
        .palette(.sunset)
      AuroraText("Ocean")
        .palette(.ocean)
      AuroraText("Forest")
        .palette(.forest)
      AuroraText("Cyberpunk")
        .palette(.cyberpunk)
    }
    .font(.system(size: 44, weight: .heavy, design: .rounded))
  }
}
