import Aurora
import SwiftUI

struct WashTuningDemo: View {
  private static let defaultSweep: Float = 0.32
  private static let defaultPulse: Float = 0.22
  private static let defaultPeak: Float = 0.28
  private static let defaultOriginX: Float = 1.0
  private static let defaultOriginY: Float = 0.5

  @State private var sweepDuration: Float = 0.32
  @State private var pulseWidth: Float = 0.22
  @State private var peak: Float = 0.28
  @State private var originX: Float = 1.0
  @State private var originY: Float = 0.5
  @State private var replayKey = 0

  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()
      AuroraGlow(.dramatic)
        .washSweepDuration(sweepDuration)
        .washPulseWidth(pulseWidth)
        .washPeak(peak)
        .washOriginX(originX)
        .washOriginY(originY)
        .ignoresSafeArea()
        .id(replayKey)
      VStack {
        Spacer()
        WashControlPanel(
          sweepDuration: $sweepDuration,
          pulseWidth: $pulseWidth,
          peak: $peak,
          originX: $originX,
          originY: $originY,
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
    originX = Self.defaultOriginX
    originY = Self.defaultOriginY
    replay()
  }
}

private struct WashControlPanel: View {
  @Binding var sweepDuration: Float
  @Binding var pulseWidth: Float
  @Binding var peak: Float
  @Binding var originX: Float
  @Binding var originY: Float
  let onReplay: () -> Void
  let onReset: () -> Void

  var body: some View {
    VStack(spacing: 14) {
      WashSlider(
        label: "Sweep",
        value: $sweepDuration,
        range: 0.05...1.0,
        format: "%.2fs"
      )
      WashSlider(
        label: "Pulse",
        value: $pulseWidth,
        range: 0.05...0.5,
        format: "%.2fs"
      )
      WashSlider(
        label: "Peak",
        value: $peak,
        range: 0.0...0.8,
        format: "%.2f"
      )
      WashSlider(
        label: "Origin X",
        value: $originX,
        range: 0.0...1.0,
        format: "%.2f"
      )
      WashSlider(
        label: "Origin Y",
        value: $originY,
        range: 0.0...1.0,
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
