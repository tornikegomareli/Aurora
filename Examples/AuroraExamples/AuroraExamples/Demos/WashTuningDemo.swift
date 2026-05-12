import Aurora
import SwiftUI

struct WashTuningDemo: View {
  private static let defaultSweep: Float = 0.12
  private static let defaultPulse: Float = 0.80
  private static let defaultPeak: Float = 0.10
  private static let defaultIntroDuration: Float = 0.5
  private static let defaultDirection: AuroraGlow.Direction = .topToBottom
  private static let defaultIntroStyle: AuroraGlow.IntroStyle = .borderFill

  @State private var sweepDuration: Float = 0.12
  @State private var pulseWidth: Float = 0.80
  @State private var peak: Float = 0.10
  @State private var introDuration: Float = 0.5
  @State private var direction: AuroraGlow.Direction = .topToBottom
  @State private var introStyle: AuroraGlow.IntroStyle = .borderFill
  @State private var replayKey = 0

  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()
      AuroraGlow(.dramatic)
        .washSweepDuration(sweepDuration)
        .washPulseWidth(pulseWidth)
        .washPeak(peak)
        .direction(direction)
        .introStyle(introStyle)
        .introDuration(introDuration)
        .ignoresSafeArea()
        .id(replayKey)
      VStack {
        Spacer()
        WashControlPanel(
          sweepDuration: $sweepDuration,
          pulseWidth: $pulseWidth,
          peak: $peak,
          introDuration: $introDuration,
          direction: $direction,
          introStyle: $introStyle,
          onReplay: replay,
          onReset: resetDefaults
        )
      }
    }
    .navigationTitle("Wash tuning")
    .navigationBarTitleDisplayMode(.inline)
    .toolbarBackground(.black, for: .navigationBar)
  }

  private func replay() {
    replayKey += 1
  }

  private func resetDefaults() {
    sweepDuration = Self.defaultSweep
    pulseWidth = Self.defaultPulse
    peak = Self.defaultPeak
    introDuration = Self.defaultIntroDuration
    direction = Self.defaultDirection
    introStyle = Self.defaultIntroStyle
    replay()
  }
}

private struct WashControlPanel: View {
  @Binding var sweepDuration: Float
  @Binding var pulseWidth: Float
  @Binding var peak: Float
  @Binding var introDuration: Float
  @Binding var direction: AuroraGlow.Direction
  @Binding var introStyle: AuroraGlow.IntroStyle
  let onReplay: () -> Void
  let onReset: () -> Void

  var body: some View {
    VStack(spacing: 12) {
      IntroStylePicker(style: $introStyle)
      DirectionPicker(direction: $direction)
      WashSlider(
        label: "Intro",
        value: $introDuration,
        range: 0.15...2.0,
        format: "%.2fs"
      )
      WashSlider(
        label: "Sweep",
        value: $sweepDuration,
        range: 0.05...1.0,
        format: "%.2fs"
      )
      WashSlider(
        label: "Pulse",
        value: $pulseWidth,
        range: 0.05...1.0,
        format: "%.2fs"
      )
      WashSlider(
        label: "Peak",
        value: $peak,
        range: 0.0...0.8,
        format: "%.2f"
      )
      HStack(spacing: 12) {
        ReplayButton(action: onReplay)
        ResetButton(action: onReset)
      }
    }
    .padding(.horizontal, 18)
    .padding(.top, 18)
    .padding(.bottom, 12)
    .background(
      .ultraThinMaterial,
      in: RoundedRectangle(cornerRadius: 24, style: .continuous)
    )
    .overlay(
      RoundedRectangle(cornerRadius: 24, style: .continuous)
        .strokeBorder(.white.opacity(0.08), lineWidth: 1)
    )
    .padding(.horizontal, 12)
    .padding(.bottom, 12)
  }
}

private struct IntroStylePicker: View {
  @Binding var style: AuroraGlow.IntroStyle

  var body: some View {
    Picker("Intro style", selection: $style) {
      Text("Thickness").tag(AuroraGlow.IntroStyle.thicknessGrow)
      Text("Border fill").tag(AuroraGlow.IntroStyle.borderFill)
      Text("Heartbeat").tag(AuroraGlow.IntroStyle.heartbeat)
    }
    .pickerStyle(.segmented)
    .colorScheme(.dark)
  }
}

private struct DirectionPicker: View {
  @Binding var direction: AuroraGlow.Direction

  var body: some View {
    Picker("Direction", selection: $direction) {
      Text("L→R").tag(AuroraGlow.Direction.leftToRight)
      Text("R→L").tag(AuroraGlow.Direction.rightToLeft)
      Text("T→B").tag(AuroraGlow.Direction.topToBottom)
      Text("B→T").tag(AuroraGlow.Direction.bottomToTop)
    }
    .pickerStyle(.segmented)
    .colorScheme(.dark)
  }
}

private struct WashSlider: View {
  let label: String
  @Binding var value: Float
  let range: ClosedRange<Float>
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
        .frame(width: 60, alignment: .trailing)
    }
  }
}

private struct ReplayButton: View {
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Label("Replay", systemImage: "sparkles")
        .font(.system(size: 15, weight: .semibold))
        .frame(maxWidth: .infinity)
        .frame(height: 44)
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

private struct ResetButton: View {
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Label("Reset", systemImage: "arrow.counterclockwise")
        .font(.system(size: 14, weight: .semibold))
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .background(.white.opacity(0.10), in: Capsule())
        .foregroundStyle(.white)
    }
  }
}

#Preview {
  NavigationStack { WashTuningDemo() }
    .preferredColorScheme(.dark)
}
