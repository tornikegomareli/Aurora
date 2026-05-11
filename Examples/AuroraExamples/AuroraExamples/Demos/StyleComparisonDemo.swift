import Aurora
import SwiftUI

struct StyleComparisonDemo: View {
  @State private var subtleBurster = AuroraGlow.Burster()
  @State private var standardBurster = AuroraGlow.Burster()
  @State private var dramaticBurster = AuroraGlow.Burster()

  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()
      ScrollView {
        VStack(spacing: 32) {
          StyleCard(style: .subtle, burster: subtleBurster)
          StyleCard(style: .standard, burster: standardBurster)
          StyleCard(style: .dramatic, burster: dramaticBurster)
        }
        .padding(24)
      }
    }
    .navigationTitle("Style comparison")
    .navigationBarTitleDisplayMode(.inline)
    .toolbarBackground(.black, for: .navigationBar)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button("Burst all", action: burstAll)
          .tint(.white)
      }
    }
  }

  private func burstAll() {
    subtleBurster.fire()
    standardBurster.fire()
    dramaticBurster.fire()
  }
}

private struct StyleCard: View {
  let style: AuroraGlow.Style
  let burster: AuroraGlow.Burster

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text(style.rawValue.capitalized)
          .font(.system(.headline, design: .rounded))
          .foregroundStyle(.white)
        Spacer()
        Text("tap to burst")
          .font(.system(.caption2, design: .monospaced))
          .foregroundStyle(.white.opacity(0.4))
      }
      RoundedRectangle(cornerRadius: 20, style: .continuous)
        .fill(Color(white: 0.06))
        .frame(height: 110)
        .glow(
          AuroraGlow(style)
            .cornerRadius(20)
            .burster(burster)
        )
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .onTapGesture { burster.fire() }
    }
  }
}

#Preview {
  NavigationStack { StyleComparisonDemo() }
    .preferredColorScheme(.dark)
}
