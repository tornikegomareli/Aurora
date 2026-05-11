import Aurora
import SwiftUI

struct CustomProfileDemo: View {
  @State private var anchorAmpBoost: Float = 0.38
  @State private var anchorSpeedBoost: Float = 2.2
  @State private var flameAmpBoost: Float = 2.0
  @State private var brightnessPop: Float = 0.32
  @State private var decayRate: Float = 1.6
  @State private var flameBaseline: Float = 0.45
  @State private var burster = AuroraGlow.Burster()

  private var profile: AuroraGlow.Profile {
    AuroraGlow.Profile(
      anchorAmpBoost: anchorAmpBoost,
      anchorSpeedBoost: anchorSpeedBoost,
      flameAmpBoost: flameAmpBoost,
      brightnessPop: brightnessPop,
      decayRate: decayRate,
      flameBaseline: flameBaseline
    )
  }

  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()
      AuroraGlow(profile: profile)
        .burster(burster)
        .ignoresSafeArea()
      VStack {
        Spacer()
        ProfilePanel(
          anchorAmpBoost: $anchorAmpBoost,
          anchorSpeedBoost: $anchorSpeedBoost,
          flameAmpBoost: $flameAmpBoost,
          brightnessPop: $brightnessPop,
          decayRate: $decayRate,
          flameBaseline: $flameBaseline,
          onBurst: { burster.fire() }
        )
      }
    }
    .navigationTitle("Custom Profile")
    .navigationBarTitleDisplayMode(.inline)
    .toolbarBackground(.black, for: .navigationBar)
  }
}

private struct ProfilePanel: View {
  @Binding var anchorAmpBoost: Float
  @Binding var anchorSpeedBoost: Float
  @Binding var flameAmpBoost: Float
  @Binding var brightnessPop: Float
  @Binding var decayRate: Float
  @Binding var flameBaseline: Float
  let onBurst: () -> Void

  var body: some View {
    VStack(spacing: 12) {
      ProfileSlider(label: "anchorAmp", value: $anchorAmpBoost, range: 0...1)
      ProfileSlider(label: "anchorSpd", value: $anchorSpeedBoost, range: 0...6)
      ProfileSlider(label: "flameAmp", value: $flameAmpBoost, range: 0...6)
      ProfileSlider(label: "brightPop", value: $brightnessPop, range: 0...1)
      ProfileSlider(label: "decayRate", value: $decayRate, range: 0.5...3)
      ProfileSlider(label: "flameBase", value: $flameBaseline, range: 0...1)
      Button(action: onBurst) {
        Label("Burst", systemImage: "sparkles")
          .font(.system(.callout, weight: .semibold))
          .frame(maxWidth: .infinity)
          .frame(height: 44)
          .background(.white.opacity(0.18), in: Capsule())
          .foregroundStyle(.white)
      }
    }
    .padding(16)
    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    .padding(.horizontal, 12)
    .padding(.bottom, 16)
  }
}

private struct ProfileSlider: View {
  let label: String
  @Binding var value: Float
  let range: ClosedRange<Float>

  var body: some View {
    HStack(spacing: 12) {
      Text(label)
        .font(.system(size: 11, weight: .medium, design: .monospaced))
        .foregroundStyle(.white.opacity(0.65))
        .frame(width: 78, alignment: .leading)
      Slider(value: $value, in: range)
        .tint(.white)
      Text(String(format: "%.2f", value))
        .font(.system(size: 11, weight: .semibold, design: .monospaced))
        .foregroundStyle(.white)
        .frame(width: 44, alignment: .trailing)
    }
  }
}

#Preview {
  NavigationStack { CustomProfileDemo() }
    .preferredColorScheme(.dark)
}
