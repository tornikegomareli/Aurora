import SwiftUI

extension View {
  /// Overlay an `AuroraGlow` ring matching the host's frame. Pass
  /// `cornerRadius` to match the host's clip shape.
  public func glow(
    _ style: AuroraGlow.Style = .standard,
    cornerRadius: CGFloat = 24
  ) -> some View {
    overlay {
      AuroraGlow(style).cornerRadius(cornerRadius)
    }
  }

  /// Overlay a pre-configured `AuroraGlow` — use when you need to
  /// tweak glow size, border, speed, or attach a `Burster`.
  public func glow(_ glow: AuroraGlow) -> some View {
    overlay { glow }
  }
}

#Preview("Cards with glow") {
  ZStack {
    Color.black.ignoresSafeArea()
    VStack(spacing: 28) {
      glowCard(title: "Subtle", style: .subtle)
      glowCard(title: "Standard", style: .standard)
      glowCard(title: "Dramatic", style: .dramatic)
    }
    .padding(24)
  }
}

@ViewBuilder
private func glowCard(
  title: String,
  style: AuroraGlow.Style
) -> some View {
  RoundedRectangle(cornerRadius: 24, style: .continuous)
    .fill(Color(white: 0.08))
    .frame(height: 90)
    .overlay {
      Text(title)
        .font(.system(size: 18, weight: .semibold, design: .rounded))
        .foregroundStyle(.white)
    }
    .glow(style, cornerRadius: 24)
}
