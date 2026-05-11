import Aurora
import SwiftUI

struct ModeDemo: View {
  @State private var mode: AuroraGlow.Mode = .edgeRing
  @State private var burster = AuroraGlow.Burster()

  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()
      AuroraGlow(.dramatic)
        .mode(mode)
        .burster(burster)
        .ignoresSafeArea()
      VStack {
        ModeLegend(mode: mode)
        Spacer()
        VStack(spacing: 12) {
          if mode == .edgeRing {
            Button {
              burster.fire()
            } label: {
              Label("Re-fire intro + burst", systemImage: "sparkles")
                .font(.system(.callout, weight: .semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(.white.opacity(0.18), in: Capsule())
                .foregroundStyle(.white)
            }
          }
          ModePicker(mode: $mode)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
      }
    }
    .navigationTitle("Modes")
    .navigationBarTitleDisplayMode(.inline)
    .toolbarBackground(.black, for: .navigationBar)
  }
}

private struct ModeLegend: View {
  let mode: AuroraGlow.Mode

  private var description: String {
    switch mode {
    case .edgeRing: return "11-anchor animated ring with burst + intro"
    case .saturated: return "Static 6-anchor blend, oversaturated"
    case .buddy: return "Static 6-anchor with contrast tone curve"
    case .noiseField: return "Animated noise × colour, full-screen"
    }
  }

  var body: some View {
    Text(description)
      .font(.system(.caption, design: .monospaced))
      .foregroundStyle(.white.opacity(0.6))
      .padding(.horizontal, 14)
      .padding(.vertical, 10)
      .background(.black.opacity(0.35), in: Capsule())
      .padding(.top, 12)
  }
}

private struct ModePicker: View {
  @Binding var mode: AuroraGlow.Mode

  var body: some View {
    Picker("Mode", selection: $mode) {
      Text("Ring").tag(AuroraGlow.Mode.edgeRing)
      Text("Saturated").tag(AuroraGlow.Mode.saturated)
      Text("Buddy").tag(AuroraGlow.Mode.buddy)
      Text("Noise").tag(AuroraGlow.Mode.noiseField)
    }
    .pickerStyle(.segmented)
    .colorScheme(.dark)
  }
}

#Preview {
  NavigationStack { ModeDemo() }
    .preferredColorScheme(.dark)
}
