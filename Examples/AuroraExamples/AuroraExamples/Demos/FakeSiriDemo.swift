import Aurora
import SwiftUI

struct FakeSiriDemo: View {
  @State private var burster = AuroraGlow.Burster()
  @State private var responseIndex = 0

  private let responses = [
    "Aurora reproduces the technique with anchored metaballs and a noise-warped SDF — no images, no GIFs, just one Metal fragment shader.",
    "The burst envelope is a damped cosine on amplitude, plus an exponential boost on anchor speed, brightness, and flame amplitude. It settles over about 3.5 seconds.",
    "Aurora ships one SwiftUI View, three presets, a Profile struct for custom tuning, and a Burster controller for re-firing the intro from outside the SwiftUI tree.",
  ]

  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()
      VStack(spacing: 24) {
        Header()
        Spacer()
        ResponseCard(text: responses[responseIndex])
          .glow(AuroraGlow(.standard).cornerRadius(22).burster(burster))
        Spacer()
        AskAgainButton(action: askAgain)
      }
      .padding(20)
    }
    .navigationTitle("Fake Siri response")
    .navigationBarTitleDisplayMode(.inline)
    .toolbarBackground(.black, for: .navigationBar)
  }

  private func askAgain() {
    responseIndex = (responseIndex + 1) % responses.count
    burster.fire()
  }
}

private struct Header: View {
  var body: some View {
    HStack(spacing: 8) {
      Image(systemName: "sparkles")
        .foregroundStyle(.white)
      Text("Ask anything")
        .font(.system(.headline, design: .rounded))
        .foregroundStyle(.white)
    }
  }
}

private struct ResponseCard: View {
  let text: String

  var body: some View {
    Text(text)
      .font(.system(.body, design: .rounded))
      .foregroundStyle(.white.opacity(0.85))
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(20)
      .background(
        Color(white: 0.07),
        in: RoundedRectangle(cornerRadius: 22, style: .continuous)
      )
  }
}

private struct AskAgainButton: View {
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Label("Ask again", systemImage: "arrow.clockwise")
        .font(.system(.callout, weight: .semibold))
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(.white.opacity(0.18), in: Capsule())
        .foregroundStyle(.white)
    }
  }
}

#Preview {
  NavigationStack { FakeSiriDemo() }
    .preferredColorScheme(.dark)
}
