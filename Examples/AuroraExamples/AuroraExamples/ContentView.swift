import SwiftUI

struct ContentView: View {
  var body: some View {
    NavigationStack {
      List(Demo.allCases) { demo in
        NavigationLink(value: demo) {
          DemoRow(demo: demo)
        }
        .listRowBackground(Color.black)
        .listRowSeparatorTint(.white.opacity(0.08))
      }
      .listStyle(.plain)
      .scrollContentBackground(.hidden)
      .background(Color.black)
      .navigationTitle("Aurora")
      .navigationDestination(for: Demo.self, destination: destination)
      .toolbarBackground(.black, for: .navigationBar)
    }
    .preferredColorScheme(.dark)
  }

  @ViewBuilder
  private func destination(for demo: Demo) -> some View {
    switch demo {
    case .hero: HeroDemo()
    case .liveTuning: LiveTuningDemo()
    case .customProfile: CustomProfileDemo()
    case .washTuning: WashTuningDemo()
    case .palettes: PaletteGalleryDemo()
    case .moods: MoodDemo()
    case .loading: LoadingDemo()
    }
  }
}

private struct DemoRow: View {
  let demo: Demo

  var body: some View {
    HStack(spacing: 14) {
      Image(systemName: demo.systemImage)
        .font(.system(size: 18, weight: .medium))
        .foregroundStyle(.white)
        .frame(width: 38, height: 38)
        .background(
          Color.white.opacity(0.08),
          in: RoundedRectangle(cornerRadius: 10, style: .continuous)
        )
      VStack(alignment: .leading, spacing: 2) {
        Text(demo.title)
          .font(.system(.body, design: .rounded, weight: .semibold))
          .foregroundStyle(.white)
        Text(demo.subtitle)
          .font(.system(.caption, design: .monospaced))
          .foregroundStyle(.white.opacity(0.5))
      }
      Spacer()
    }
    .padding(.vertical, 4)
  }
}

#Preview {
  ContentView()
}
