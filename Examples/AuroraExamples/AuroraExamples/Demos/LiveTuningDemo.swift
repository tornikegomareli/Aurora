import Aurora
import SwiftUI

struct LiveTuningDemo: View {
  private static let defaultCornerRadius: CGFloat = 55
  private static let defaultBorderWidth: CGFloat = 6
  private static let defaultGlowSize: CGFloat = 28
  private static let defaultSpeed: Double = 0.12

  @State private var isVisible = true
  @State private var style: AuroraGlow.Style = .standard
  @State private var cornerRadius: CGFloat = 55
  @State private var borderWidth: CGFloat = 6
  @State private var glowSize: CGFloat = 28
  @State private var speed: Double = 0.12
  @State private var burster = AuroraGlow.Burster()

  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()
      if isVisible {
        AuroraGlow(style)
          .cornerRadius(cornerRadius)
          .borderWidth(borderWidth)
          .glowSize(glowSize)
          .speed(speed)
          .burster(burster)
          .ignoresSafeArea()
          .transition(.opacity)
      }
      VStack {
        Spacer()
        ControlPanel(
          style: $style,
          cornerRadius: $cornerRadius,
          borderWidth: $borderWidth,
          glowSize: $glowSize,
          speed: $speed,
          isVisible: isVisible,
          onStyleChange: triggerBurst,
          onTriggerBurst: triggerBurst,
          onToggleVisibility: toggleVisibility,
          onReset: resetDefaults
        )
      }
    }
    .navigationTitle("Live tuning")
    .navigationBarTitleDisplayMode(.inline)
    .toolbarBackground(.black, for: .navigationBar)
    .animation(.easeInOut(duration: 0.25), value: isVisible)
  }

  private func toggleVisibility() {
    let wasVisible = isVisible
    isVisible.toggle()
    if !wasVisible { burster.fire() }
  }

  private func resetDefaults() {
    cornerRadius = Self.defaultCornerRadius
    borderWidth = Self.defaultBorderWidth
    glowSize = Self.defaultGlowSize
    speed = Self.defaultSpeed
    burster.fire()
  }

  private func triggerBurst() {
    burster.fire()
  }
}

private struct ControlPanel: View {
  @Binding var style: AuroraGlow.Style
  @Binding var cornerRadius: CGFloat
  @Binding var borderWidth: CGFloat
  @Binding var glowSize: CGFloat
  @Binding var speed: Double
  let isVisible: Bool
  let onStyleChange: () -> Void
  let onTriggerBurst: () -> Void
  let onToggleVisibility: () -> Void
  let onReset: () -> Void

  var body: some View {
    VStack(spacing: 14) {
      StylePicker(style: $style, onChange: onStyleChange)
      SliderRow(label: "Corner", value: $cornerRadius, range: 0...120, format: "%.0f")
      SliderRow(label: "Border", value: $borderWidth, range: 1...24, format: "%.1f")
      SliderRow(label: "Glow", value: $glowSize, range: 4...120, format: "%.0f")
      SliderRow(
        label: "Speed",
        value: Binding(
          get: { CGFloat(speed) },
          set: { speed = Double($0) }
        ),
        range: 0.02...0.6,
        format: "%.2f"
      )
      BurstButton(action: onTriggerBurst)
      HStack(spacing: 12) {
        VisibilityButton(isVisible: isVisible, action: onToggleVisibility)
        ResetButton(action: onReset)
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
    .padding(.bottom, 12)
  }
}

private struct StylePicker: View {
  @Binding var style: AuroraGlow.Style
  let onChange: () -> Void

  var body: some View {
    Picker("Style", selection: $style) {
      ForEach(AuroraGlow.Style.allCases, id: \.self) { s in
        Text(s.rawValue.capitalized).tag(s)
      }
    }
    .pickerStyle(.segmented)
    .colorScheme(.dark)
    .onChange(of: style) { _, _ in onChange() }
  }
}

private struct SliderRow: View {
  let label: String
  @Binding var value: CGFloat
  let range: ClosedRange<CGFloat>
  let format: String

  var body: some View {
    HStack(spacing: 12) {
      Text(label)
        .font(.system(size: 12, weight: .medium, design: .monospaced))
        .foregroundStyle(.white.opacity(0.65))
        .frame(width: 56, alignment: .leading)
      Slider(value: $value, in: range)
        .tint(.white)
      Text(String(format: format, value))
        .font(.system(size: 12, weight: .semibold, design: .monospaced))
        .foregroundStyle(.white)
        .frame(width: 52, alignment: .trailing)
    }
  }
}

private struct BurstButton: View {
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Label("Trigger burst", systemImage: "sparkles")
        .font(.system(size: 15, weight: .semibold))
        .frame(maxWidth: .infinity)
        .frame(height: 46)
        .background(
          LinearGradient(
            colors: [
              Color(red: 0.984, green: 0.392, blue: 1.000),
              Color(red: 1.000, green: 0.145, blue: 0.333),
              Color(red: 1.000, green: 0.577, blue: 0.000),
            ],
            startPoint: .leading,
            endPoint: .trailing
          ),
          in: Capsule()
        )
        .foregroundStyle(.white)
    }
  }
}

private struct VisibilityButton: View {
  let isVisible: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Label(
        isVisible ? "Hide glow" : "Show glow",
        systemImage: isVisible ? "eye.slash.fill" : "eye.fill"
      )
      .font(.system(size: 14, weight: .semibold))
      .frame(maxWidth: .infinity)
      .frame(height: 40)
      .background(.white.opacity(0.18), in: Capsule())
      .foregroundStyle(.white)
    }
  }
}

private struct ResetButton: View {
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Label("Reset", systemImage: "arrow.counterclockwise")
        .font(.system(size: 14, weight: .semibold))
        .frame(maxWidth: .infinity)
        .frame(height: 40)
        .background(.white.opacity(0.10), in: Capsule())
        .foregroundStyle(.white)
    }
  }
}

#Preview {
  NavigationStack { LiveTuningDemo() }
    .preferredColorScheme(.dark)
}
