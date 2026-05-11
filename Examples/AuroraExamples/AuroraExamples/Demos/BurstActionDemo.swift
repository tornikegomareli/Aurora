import Aurora
import SwiftUI

struct BurstActionDemo: View {
  @State private var prompt = ""
  @State private var burster = AuroraGlow.Burster()
  @State private var lastSubmitted: String?

  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()
      VStack(spacing: 24) {
        Spacer()
        SubmittedAnswer(text: lastSubmitted)
        Spacer()
        PromptField(text: $prompt, onSubmit: submit)
          .glow(AuroraGlow(.standard).cornerRadius(28).burster(burster))
      }
      .padding(.horizontal, 20)
      .padding(.bottom, 24)
    }
    .navigationTitle("Burst on action")
    .navigationBarTitleDisplayMode(.inline)
    .toolbarBackground(.black, for: .navigationBar)
  }

  private func submit() {
    let trimmed = prompt.trimmingCharacters(in: .whitespaces)
    guard !trimmed.isEmpty else { return }
    lastSubmitted = trimmed
    prompt = ""
    burster.fire()
  }
}

private struct PromptField: View {
  @Binding var text: String
  let onSubmit: () -> Void

  var body: some View {
    HStack(spacing: 10) {
      TextField("Ask anything…", text: $text)
        .textFieldStyle(.plain)
        .font(.system(.body, design: .rounded))
        .foregroundStyle(.white)
        .submitLabel(.send)
        .onSubmit(onSubmit)
      Button(action: onSubmit) {
        Image(systemName: "arrow.up.circle.fill")
          .font(.system(size: 30))
          .foregroundStyle(.white)
      }
    }
    .padding(.horizontal, 18)
    .padding(.vertical, 12)
    .background(Color(white: 0.07), in: Capsule())
  }
}

private struct SubmittedAnswer: View {
  let text: String?

  var body: some View {
    if let text {
      VStack(alignment: .leading, spacing: 8) {
        Text("you asked")
          .font(.system(.caption, design: .monospaced))
          .foregroundStyle(.white.opacity(0.4))
        Text(text)
          .font(.system(.title3, design: .rounded))
          .foregroundStyle(.white)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(20)
      .background(
        Color(white: 0.07),
        in: RoundedRectangle(cornerRadius: 18, style: .continuous)
      )
    } else {
      Text("Type a question and hit send to fire the burst.")
        .font(.system(.callout, design: .monospaced))
        .foregroundStyle(.white.opacity(0.4))
        .multilineTextAlignment(.center)
    }
  }
}

#Preview {
  NavigationStack { BurstActionDemo() }
    .preferredColorScheme(.dark)
}
