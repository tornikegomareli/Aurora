import Aurora
import SwiftUI

struct LoadingDemo: View {
  @State private var isLoading = false
  @State private var lastResult: String?

  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()
      VStack(spacing: 24) {
        Spacer()
        ResponseCard(text: lastResult, isLoading: isLoading)
          .glowWhileLoading(isLoading, style: .standard, cornerRadius: 22)
        Spacer()
        ActionButton(isLoading: isLoading, action: runFakeRequest)
      }
      .padding(24)
    }
    .navigationTitle("glowWhileLoading")
    .navigationBarTitleDisplayMode(.inline)
    .toolbarBackground(.black, for: .navigationBar)
  }

  private func runFakeRequest() {
    guard !isLoading else { return }
    lastResult = nil
    isLoading = true
    Task {
      try? await Task.sleep(for: .seconds(2.5))
      lastResult = "Done — the glow above played its intro on start, held while loading, and is now playing its outro."
      isLoading = false
    }
  }
}

private struct ResponseCard: View {
  let text: String?
  let isLoading: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Label(
        isLoading ? "thinking…" : (text == nil ? "tap below" : "response"),
        systemImage: isLoading ? "sparkles" : "checkmark.circle.fill"
      )
      .font(.system(.caption, design: .monospaced))
      .foregroundStyle(.white.opacity(0.5))
      Text(text ?? "Aurora's `.glowWhileLoading(_:)` modifier wraps any view and shows the glow only while the loading flag is true.")
        .font(.system(.body, design: .rounded))
        .foregroundStyle(.white.opacity(0.85))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    .padding(20)
    .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
    .background(Color(white: 0.07), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
  }
}

private struct ActionButton: View {
  let isLoading: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Label(
        isLoading ? "Loading…" : "Fake load 2.5s",
        systemImage: isLoading ? "circle.dotted" : "play.fill"
      )
      .font(.system(.callout, weight: .semibold))
      .frame(maxWidth: .infinity)
      .frame(height: 50)
      .background(
        isLoading ? Color.white.opacity(0.10) : Color.white.opacity(0.18),
        in: Capsule()
      )
      .foregroundStyle(.white)
    }
    .disabled(isLoading)
  }
}

#Preview {
  NavigationStack { LoadingDemo() }
    .preferredColorScheme(.dark)
}
