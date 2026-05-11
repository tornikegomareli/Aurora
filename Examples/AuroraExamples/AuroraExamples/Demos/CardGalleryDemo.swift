import Aurora
import SwiftUI

struct CardGalleryDemo: View {
  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()
      ScrollView {
        VStack(spacing: 24) {
          ChatBubbleCard()
          SettingsRowCard()
          ProfileCard()
          ActionButtonCard()
        }
        .padding(24)
      }
    }
    .navigationTitle(".glow on cards")
    .navigationBarTitleDisplayMode(.inline)
    .toolbarBackground(.black, for: .navigationBar)
  }
}

private struct ChatBubbleCard: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Label("Chat bubble", systemImage: "bubble.left.fill")
        .font(.system(.caption, design: .monospaced))
        .foregroundStyle(.white.opacity(0.5))
      RoundedRectangle(cornerRadius: 22, style: .continuous)
        .fill(Color(white: 0.07))
        .frame(height: 120)
        .overlay(alignment: .topLeading) {
          Text("Aurora draws an animated ring around any view with one Metal shader.")
            .font(.system(.body, design: .rounded))
            .foregroundStyle(.white.opacity(0.85))
            .padding(18)
        }
        .glow(.subtle, cornerRadius: 22)
    }
  }
}

private struct SettingsRowCard: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Label("Settings row", systemImage: "list.bullet.rectangle.fill")
        .font(.system(.caption, design: .monospaced))
        .foregroundStyle(.white.opacity(0.5))
      HStack(spacing: 14) {
        Image(systemName: "bell.fill")
          .font(.system(size: 17, weight: .medium))
          .foregroundStyle(.white)
          .frame(width: 32, height: 32)
          .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
        Text("Notifications")
          .font(.system(.body, design: .rounded, weight: .semibold))
          .foregroundStyle(.white)
        Spacer()
        Image(systemName: "chevron.right")
          .foregroundStyle(.white.opacity(0.5))
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 14)
      .background(Color(white: 0.07), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
      .glow(.standard, cornerRadius: 16)
    }
  }
}

private struct ProfileCard: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Label("Profile card", systemImage: "person.crop.rectangle.fill")
        .font(.system(.caption, design: .monospaced))
        .foregroundStyle(.white.opacity(0.5))
      HStack(spacing: 14) {
        Circle()
          .fill(LinearGradient(
            colors: [
              Color(red: 0.984, green: 0.392, blue: 1.000),
              Color(red: 1.000, green: 0.577, blue: 0.000),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          ))
          .frame(width: 52, height: 52)
          .overlay(
            Text("π")
              .font(.system(size: 24, weight: .semibold, design: .serif))
              .foregroundStyle(.white)
          )
        VStack(alignment: .leading, spacing: 3) {
          Text("Pi Coding Agent")
            .font(.system(.headline, design: .rounded))
            .foregroundStyle(.white)
          Text("Available")
            .font(.system(.caption, design: .monospaced))
            .foregroundStyle(.white.opacity(0.5))
        }
        Spacer()
      }
      .padding(18)
      .background(Color(white: 0.07), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
      .glow(.dramatic, cornerRadius: 22)
    }
  }
}

private struct ActionButtonCard: View {
  @State private var burster = AuroraGlow.Burster()

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Label("Glowing button", systemImage: "hand.tap.fill")
        .font(.system(.caption, design: .monospaced))
        .foregroundStyle(.white.opacity(0.5))
      Button { burster.fire() } label: {
        Text("Tap to burst")
          .font(.system(.body, design: .rounded, weight: .semibold))
          .frame(maxWidth: .infinity)
          .frame(height: 56)
          .background(Color(white: 0.07), in: Capsule())
          .foregroundStyle(.white)
      }
      .glow(AuroraGlow(.standard).cornerRadius(28).burster(burster))
    }
  }
}

#Preview {
  NavigationStack { CardGalleryDemo() }
    .preferredColorScheme(.dark)
}
