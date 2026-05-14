import Aurora
import SwiftUI

struct TextDemo: View {
  @State private var selectedIndex = 0
  @State private var streamed: String = ""
  @State private var isStreaming = false
  @State private var speed: Double = 0.12

  private let entries: [(name: String, palette: AuroraGlow.Palette)] = [
    ("Apple Intelligence", .appleIntelligence),
    ("Sunset", .sunset),
    ("Ocean", .ocean),
    ("Forest", .forest),
    ("Monochrome", .monochrome),
    ("Cyberpunk", .cyberpunk),
  ]

  private let fullResponse =
    "Hi, I'm Aurora.\nI shimmer while I think,\nthen settle when I'm done."

  private var palette: AuroraGlow.Palette { entries[selectedIndex].palette }

  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()

      VStack(spacing: 32) {
        Spacer()

        AuroraText("Aurora\nIntelligence")
          .palette(palette)
          .speed(speed)
          .font(.system(size: 52, weight: .heavy, design: .rounded))
          .multilineTextAlignment(.center)

        AuroraText(streamed.isEmpty ? " " : streamed)
          .palette(palette)
          .speed(speed)
          .font(.system(size: 22, weight: .semibold, design: .rounded))
          .multilineTextAlignment(.center)
          .padding(.horizontal, 24)
          .frame(minHeight: 110)

        streamButton

        Spacer()

        SpeedSlider(value: $speed)

        PaletteRow(
          entries: entries,
          selectedIndex: $selectedIndex
        )
      }
      .padding(.bottom, 12)
    }
    .overlay {
      AuroraGlow(.standard)
        .palette(palette)
        .ignoresSafeArea()
        .id(selectedIndex)
    }
    .navigationTitle("AuroraText")
    .navigationBarTitleDisplayMode(.inline)
    .toolbarBackground(.black, for: .navigationBar)
  }

  private var streamButton: some View {
    Button(action: streamResponse) {
      Text(isStreaming ? "Streaming…" : "Stream a response")
        .font(.system(size: 14, weight: .semibold, design: .rounded))
        .foregroundStyle(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 11)
        .background(
          Color.white.opacity(0.10),
          in: Capsule()
        )
        .overlay(
          Capsule().strokeBorder(.white.opacity(0.15), lineWidth: 1)
        )
    }
    .disabled(isStreaming)
  }

  private func streamResponse() {
    isStreaming = true
    streamed = ""
    Task {
      for ch in fullResponse {
        try? await Task.sleep(for: .milliseconds(28))
        streamed.append(ch)
      }
      isStreaming = false
    }
  }
}

private struct SpeedSlider: View {
  @Binding var value: Double

  var body: some View {
    HStack(spacing: 12) {
      Text("Speed")
        .font(.system(size: 12, weight: .medium, design: .monospaced))
        .foregroundStyle(.white.opacity(0.65))
        .frame(width: 56, alignment: .leading)
      Slider(value: $value, in: 0.02...0.6)
        .tint(.white)
      Text(String(format: "%.2f", value))
        .font(.system(size: 12, weight: .semibold, design: .monospaced))
        .foregroundStyle(.white)
        .frame(width: 52, alignment: .trailing)
    }
    .padding(.horizontal, 18)
    .padding(.vertical, 10)
    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    .overlay(
      RoundedRectangle(cornerRadius: 16, style: .continuous)
        .strokeBorder(.white.opacity(0.08), lineWidth: 1)
    )
    .padding(.horizontal, 16)
  }
}

private struct PaletteRow: View {
  let entries: [(name: String, palette: AuroraGlow.Palette)]
  @Binding var selectedIndex: Int

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 12) {
        ForEach(entries.indices, id: \.self) { i in
          PaletteSwatch(
            name: entries[i].name,
            palette: entries[i].palette,
            isSelected: i == selectedIndex
          )
          .onTapGesture { selectedIndex = i }
        }
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 14)
    }
    .background(.ultraThinMaterial)
  }
}

private struct PaletteSwatch: View {
  let name: String
  let palette: AuroraGlow.Palette
  let isSelected: Bool

  var body: some View {
    VStack(spacing: 6) {
      HStack(spacing: 2) {
        ForEach(palette.anchors.indices, id: \.self) { i in
          let c = palette.anchors[i]
          Rectangle()
            .fill(Color(red: Double(c.x), green: Double(c.y), blue: Double(c.z)))
            .frame(width: 14, height: 28)
        }
      }
      .clipShape(RoundedRectangle(cornerRadius: 4))
      .overlay(
        RoundedRectangle(cornerRadius: 4)
          .strokeBorder(.white.opacity(isSelected ? 0.6 : 0.12), lineWidth: 1)
      )
      Text(name)
        .font(.system(size: 10, weight: .medium, design: .monospaced))
        .foregroundStyle(.white.opacity(isSelected ? 0.95 : 0.55))
    }
    .padding(8)
    .background(
      isSelected ? Color.white.opacity(0.06) : Color.clear,
      in: RoundedRectangle(cornerRadius: 8)
    )
  }
}

#Preview {
  NavigationStack { TextDemo() }
    .preferredColorScheme(.dark)
}
