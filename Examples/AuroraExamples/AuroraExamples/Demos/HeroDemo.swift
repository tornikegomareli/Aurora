import Aurora
import SwiftUI

struct HeroDemo: View {
  @State private var burster = AuroraGlow.Burster()

  var body: some View {
    ZStack {
        
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .overlay {
      AuroraGlow(.standard).ignoresSafeArea() }
  }
}

#Preview {
  NavigationStack { HeroDemo() }
    .preferredColorScheme(.dark)
}
