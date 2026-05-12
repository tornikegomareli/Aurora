import Aurora
import SwiftUI

struct PaletteGalleryDemo: View {
  @State private var selectedIndex = 0

  private let entries: [(name: String, palette: AuroraGlow.Palette)] = [
    ("Apple Intelligence", .appleIntelligence),
    ("Sunset", .sunset),
    ("Ocean", .ocean),
    ("Forest", .forest),
    ("Monochrome", .monochrome),
    ("Cyberpunk", .cyberpunk),
  ]

  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()
      AuroraGlow(.standard)
        .palette(entries[selectedIndex].palette)
        .ignoresSafeArea()
        .id(selectedIndex)
      VStack {
        Spacer()
        Text(entries[selectedIndex].name)
          .font(.system(size: 34, weight: .light, design: .serif))
          .foregroundStyle(.white)
        Spacer()
        PaletteList(
          entries: entries,
          selectedIndex: $selectedIndex
        )
      }
    }
    .navigationTitle("Palettes")
    .navigationBarTitleDisplayMode(.inline)
    .toolbarBackground(.black, for: .navigationBar)
  }
}

private struct PaletteList: View {
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
    .padding(.bottom, 12)
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
  NavigationStack { PaletteGalleryDemo() }
    .preferredColorScheme(.dark)
}
