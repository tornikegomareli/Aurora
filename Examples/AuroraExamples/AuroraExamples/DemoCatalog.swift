import SwiftUI

enum Demo: String, CaseIterable, Identifiable {
  case hero
  case liveTuning
  case customProfile

  var id: String { rawValue }

  var title: String {
    switch self {
    case .hero: return "Hero"
    case .liveTuning: return "Live tuning"
    case .customProfile: return "Custom Profile"
    }
  }

  var subtitle: String {
    switch self {
    case .hero: return "Full-screen dramatic glow"
    case .liveTuning: return "Tweak every knob live"
    case .customProfile: return "Build a Profile by hand"
    }
  }

  var systemImage: String {
    switch self {
    case .hero: return "star.fill"
    case .liveTuning: return "slider.horizontal.3"
    case .customProfile: return "waveform.path"
    }
  }
}
