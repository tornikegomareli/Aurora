import SwiftUI

enum Demo: String, CaseIterable, Identifiable {
  case hero
  case liveTuning
  case customProfile
  case washTuning

  var id: String { rawValue }

  var title: String {
    switch self {
    case .hero: return "Hero"
    case .liveTuning: return "Live tuning"
    case .customProfile: return "Custom Profile"
    case .washTuning: return "Wash tuning"
    }
  }

  var subtitle: String {
    switch self {
    case .hero: return "Full-screen dramatic glow"
    case .liveTuning: return "Tweak every knob live"
    case .customProfile: return "Build a Profile by hand"
    case .washTuning: return "Dial the intro wash pulse"
    }
  }

  var systemImage: String {
    switch self {
    case .hero: return "star.fill"
    case .liveTuning: return "slider.horizontal.3"
    case .customProfile: return "waveform.path"
    case .washTuning: return "drop.fill"
    }
  }
}
