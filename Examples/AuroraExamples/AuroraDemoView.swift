import Aurora
import SwiftUI

/// Sandbox screen for tuning `AuroraGlow` on a real device or
/// in the Xcode preview canvas. Four sliders pipe straight into the
/// shader uniforms, a segmented control switches between the three
/// `Style` presets, a button re-fires the burst envelope, and a toggle
/// hides/shows the glow so the un-glowed background is comparable.
///
/// ## How to run it
///
/// - **Xcode previews**: open this file in Xcode and use the preview
///   canvas. Previews are interactive on Apple Silicon Macs, so the
///   shader updates live as you drag sliders.
/// - **Host app**: render `AuroraDemoView()` as your
///   scene's root content. The view has no external dependencies
///   beyond `Aurora` itself.
public struct AuroraDemoView: View {

  public init() {}

  // Tweakable parameters live as @State so the sliders drive them live.
  @State private var isVisible = true
  @State private var style: AuroraGlow.Style = .standard
  @State private var cornerRadius: CGFloat = 55
  @State private var borderWidth: CGFloat = 6
  @State private var glowSize: CGFloat = 28
  @State private var speed: Double = 0.12
  @State private var controlsCollapsed = false
  @State private var burstCount: Int = 0

  // Defaults match the component's own defaults.
  private static let defaultCornerRadius: CGFloat = 55
  private static let defaultBorderWidth: CGFloat = 6
  private static let defaultGlowSize: CGFloat = 28
  private static let defaultSpeed: Double = 0.12

  public var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()
      contentBehindGlow
      if isVisible {
        AuroraGlow(
          style: style,
          cornerRadius: cornerRadius,
          borderWidth: borderWidth,
          glowSize: glowSize,
          speed: speed,
          burstTrigger: burstCount
        )
        .ignoresSafeArea()
        .transition(.opacity)
      }
      VStack(spacing: 0) {
        Spacer()
        if !controlsCollapsed { controlPanel }
        toggleControlsBar
      }
    }
    .preferredColorScheme(.dark)
    .animation(.easeInOut(duration: 0.25), value: isVisible)
    .animation(.spring(duration: 0.35), value: controlsCollapsed)
  }

  // MARK: - Backdrop

  private var contentBehindGlow: some View {
    VStack(spacing: 8) {
      Text("π")
        .font(.system(size: 84, weight: .light, design: .serif))
        .foregroundStyle(.white.opacity(0.85))
      Text("Aurora Glow")
        .font(.system(size: 18, weight: .semibold, design: .rounded))
        .foregroundStyle(.white.opacity(0.7))
      Text("Live-tune the shader")
        .font(.system(size: 13, design: .monospaced))
        .foregroundStyle(.white.opacity(0.35))
    }
  }

  // MARK: - Controls

  private var controlPanel: some View {
    VStack(spacing: 14) {
      header

      stylePicker

      sliderRow(label: "Corner",
                value: $cornerRadius,
                range: 0...120,
                format: "%.0f")
      sliderRow(label: "Border",
                value: $borderWidth,
                range: 1...24,
                format: "%.1f")
      sliderRow(label: "Glow",
                value: $glowSize,
                range: 4...120,
                format: "%.0f")
      sliderRow(label: "Speed",
                value: Binding(
                  get: { CGFloat(speed) },
                  set: { speed = Double($0) }
                ),
                range: 0.02...0.6,
                format: "%.2f")

      // Primary action: re-fire the burst envelope.
      Button(action: triggerBurst) {
        Label("Trigger burst", systemImage: "sparkles")
          .font(.system(size: 15, weight: .semibold))
          .frame(maxWidth: .infinity)
          .frame(height: 46)
          .background(
            LinearGradient(
              colors: [
                Color(red: 0.984, green: 0.392, blue: 1.000),  // purple
                Color(red: 1.000, green: 0.145, blue: 0.333),  // pink
                Color(red: 1.000, green: 0.577, blue: 0.000),  // orange
              ],
              startPoint: .leading,
              endPoint: .trailing
            ),
            in: Capsule()
          )
          .foregroundStyle(.white)
      }

      HStack(spacing: 12) {
        Button(action: toggleVisibility) {
          Label(isVisible ? "Hide glow" : "Show glow",
                systemImage: isVisible ? "eye.slash.fill" : "eye.fill")
            .font(.system(size: 14, weight: .semibold))
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(.white.opacity(0.18), in: Capsule())
            .foregroundStyle(.white)
        }
        Button(action: resetDefaults) {
          Label("Reset", systemImage: "arrow.counterclockwise")
            .font(.system(size: 14, weight: .semibold))
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(.white.opacity(0.10), in: Capsule())
            .foregroundStyle(.white)
        }
      }
    }
    .padding(.horizontal, 18)
    .padding(.top, 18)
    .padding(.bottom, 12)
    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    .overlay(
      RoundedRectangle(cornerRadius: 24, style: .continuous)
        .strokeBorder(.white.opacity(0.08), lineWidth: 1)
    )
    .padding(.horizontal, 12)
  }

  private var header: some View {
    HStack {
      Image(systemName: "wand.and.stars")
        .font(.system(size: 14, weight: .semibold))
      Text("Live tweak")
        .font(.system(size: 14, weight: .semibold))
      Spacer()
      Text("\(activeChipCount) on")
        .font(.system(size: 11, design: .monospaced))
        .foregroundStyle(.white.opacity(0.55))
    }
    .foregroundStyle(.white)
  }

  private var stylePicker: some View {
    Picker("Style", selection: $style) {
      ForEach(AuroraGlow.Style.allCases, id: \.self) { s in
        Text(s.rawValue.capitalized).tag(s)
      }
    }
    .pickerStyle(.segmented)
    .colorScheme(.dark)
    .onChange(of: style) { _, _ in
      burstCount &+= 1   // re-fire burst so the style change is visible
    }
  }

  private var toggleControlsBar: some View {
    Button(action: { controlsCollapsed.toggle() }) {
      HStack(spacing: 6) {
        Image(systemName: controlsCollapsed ? "chevron.up" : "chevron.down")
          .font(.system(size: 10, weight: .bold))
        Text(controlsCollapsed ? "Show controls" : "Hide controls")
          .font(.system(size: 11, weight: .medium, design: .monospaced))
      }
      .foregroundStyle(.white.opacity(0.6))
      .padding(.horizontal, 14)
      .padding(.vertical, 8)
      .background(.black.opacity(0.4), in: Capsule())
    }
    .padding(.top, 8)
    .padding(.bottom, 16)
  }

  private func sliderRow(
    label: String,
    value: Binding<CGFloat>,
    range: ClosedRange<CGFloat>,
    format: String
  ) -> some View {
    HStack(spacing: 12) {
      Text(label)
        .font(.system(size: 12, weight: .medium, design: .monospaced))
        .foregroundStyle(.white.opacity(0.65))
        .frame(width: 56, alignment: .leading)
      Slider(value: value, in: range)
        .tint(.white)
      Text(String(format: format, value.wrappedValue))
        .font(.system(size: 12, weight: .semibold, design: .monospaced))
        .foregroundStyle(.white)
        .frame(width: 52, alignment: .trailing)
    }
  }

  // MARK: - Actions

  private func toggleVisibility() {
    let wasVisible = isVisible
    isVisible.toggle()
    // Re-burst on show so toggling the glow on always shows the
    // characteristic Apple-Intelligence intro animation.
    if !wasVisible {
      burstCount &+= 1
    }
  }

  private func resetDefaults() {
    cornerRadius = Self.defaultCornerRadius
    borderWidth = Self.defaultBorderWidth
    glowSize = Self.defaultGlowSize
    speed = Self.defaultSpeed
    burstCount &+= 1
  }

  private func triggerBurst() {
    burstCount &+= 1
  }

  private var activeChipCount: String {
    isVisible ? "glow" : "off"
  }
}

#Preview("Default") {
  AuroraDemoView()
}

#Preview("Hidden controls") {
  AuroraDemoView()
    .onAppear { /* user can tap chevron to hide */ }
}
