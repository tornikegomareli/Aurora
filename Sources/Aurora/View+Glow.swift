import SwiftUI

extension View {

  /// Overlay an `AuroraGlow` ring matching the host view's frame.
  ///
  /// The shortest path to a glowing card or button:
  ///
  /// ```swift
  /// Card()
  ///   .padding()
  ///   .glow(.standard, cornerRadius: 24)
  /// ```
  ///
  /// `cornerRadius` should match whatever clip shape your host view
  /// uses so the glow band lines up with the visible edge.
  ///
  /// - Parameters:
  ///   - style: which preset feel to use. Defaults to `.standard`.
  ///   - cornerRadius: corner radius of the glow's rounded-rect band.
  ///     Defaults to `24`.
  public func glow(
    _ style: AuroraGlow.Style = .standard,
    cornerRadius: CGFloat = 24
  ) -> some View {
    overlay {
      AuroraGlow(style).cornerRadius(cornerRadius)
    }
  }

  /// Overlay a pre-configured `AuroraGlow`. Use this when you need
  /// more than corner radius — adjusting `glowSize`, `borderWidth`,
  /// `speed`, or attaching a `Burster`.
  ///
  /// ```swift
  /// @State private var burster = AuroraGlow.Burster()
  ///
  /// Card().glow(
  ///   AuroraGlow(.dramatic)
  ///     .cornerRadius(24)
  ///     .borderWidth(8)
  ///     .burster(burster)
  /// )
  /// ```
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
