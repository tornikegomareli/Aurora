import Aurora
import SwiftUI

struct MoodDemo: View {
  @State private var mood: AuroraGlow.Mood = .neutral

  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()
      AuroraGlow(.standard)
        .mood(mood)
        .ignoresSafeArea()
        .id(mood)
      VStack(spacing: 14) {
        Spacer()
        Text(label(for: mood))
          .font(.system(size: 38, weight: .light, design: .serif))
          .foregroundStyle(.white)
        Text(subtitle(for: mood))
          .font(.system(.callout, design: .monospaced))
          .foregroundStyle(.white.opacity(0.55))
          .multilineTextAlignment(.center)
        Spacer()
        MoodPicker(mood: $mood)
          .padding(.bottom, 16)
      }
      .padding(.horizontal, 24)
    }
    .navigationTitle("Mood")
    .navigationBarTitleDisplayMode(.inline)
    .toolbarBackground(.black, for: .navigationBar)
  }

  private func label(for mood: AuroraGlow.Mood) -> String {
    switch mood {
    case .neutral:   return "neutral"
    case .listening: return "listening"
    case .thinking:  return "thinking"
    case .error:     return "error"
    case .success:   return "success"
    }
  }

  private func subtitle(for mood: AuroraGlow.Mood) -> String {
    switch mood {
    case .neutral:   return "default palette, default speed"
    case .listening: return "default palette, faster pace"
    case .thinking:  return "ocean palette, slower pace"
    case .error:     return "red-shifted palette"
    case .success:   return "green palette"
    }
  }
}

private struct MoodPicker: View {
  @Binding var mood: AuroraGlow.Mood

  var body: some View {
    HStack(spacing: 8) {
      ForEach(AuroraGlow.Mood.allCases, id: \.self) { value in
        MoodChip(
          mood: value,
          isSelected: value == mood
        )
        .onTapGesture { mood = value }
      }
    }
  }
}

private struct MoodChip: View {
  let mood: AuroraGlow.Mood
  let isSelected: Bool

  var body: some View {
    Text(mood.rawValue)
      .font(.system(size: 11, weight: .semibold, design: .monospaced))
      .padding(.horizontal, 10)
      .padding(.vertical, 8)
      .frame(maxWidth: .infinity)
      .background(
        isSelected ? Color.white.opacity(0.22) : Color.white.opacity(0.06),
        in: Capsule()
      )
      .foregroundStyle(.white)
  }
}

#Preview {
  NavigationStack { MoodDemo() }
    .preferredColorScheme(.dark)
}
