import Aurora
import SwiftUI

struct HeroDemo: View {
  @State private var burster = AuroraGlow.Burster()

  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()
      AuroraGlow(.dramatic)
        .burster(burster)
        .ignoresSafeArea()
      VStack(spacing: 14) {
        Text("Aurora")
          .font(.system(size: 72, weight: .light, design: .serif))
          .foregroundStyle(.white)
        Text("the Apple-Intelligence glow,\nin SwiftUI")
          .font(.system(.body, design: .rounded))
          .foregroundStyle(.white.opacity(0.55))
          .multilineTextAlignment(.center)
      }
    }
    .navigationTitle("Hero")
    .navigationBarTitleDisplayMode(.inline)
    .toolbarBackground(.black, for: .navigationBar)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button { burster.fire() } label: {
          Image(systemName: "sparkles")
        }
        .tint(.white)
      }
    }
  }
}

#Preview {
  NavigationStack { HeroDemo() }
    .preferredColorScheme(.dark)
}
