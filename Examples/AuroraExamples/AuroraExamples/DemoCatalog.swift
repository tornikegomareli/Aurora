import SwiftUI

enum Demo: String, CaseIterable, Identifiable {
  case hero
  case text
  case liveTuning
  case customProfile
  case washTuning
  case palettes
  case moods
  case loading

  var id: String { rawValue }

  var title: String {
    switch self {
    case .hero: return "Hero"
    case .text: return "AuroraText"
    case .liveTuning: return "Live tuning"
    case .customProfile: return "Custom Profile"
    case .washTuning: return "Wash tuning"
    case .palettes: return "Palettes"
    case .moods: return "Moods"
    case .loading: return "glowWhileLoading"
    }
  }

  var subtitle: String {
    switch self {
    case .hero: return "Full-screen dramatic glow"
    case .text: return "Shimmering Apple-Intelligence text"
    case .liveTuning: return "Tweak every knob live"
    case .customProfile: return "Build a Profile by hand"
    case .washTuning: return "Dial the intro wash pulse"
    case .palettes: return "Six built-in colour sets"
    case .moods: return "Semantic state presets"
    case .loading: return "Async loading wrapper"
    }
  }

  var systemImage: String {
    switch self {
    case .hero: return "star.fill"
    case .text: return "textformat.alt"
    case .liveTuning: return "slider.horizontal.3"
    case .customProfile: return "waveform.path"
    case .washTuning: return "drop.fill"
    case .palettes: return "paintpalette.fill"
    case .moods: return "face.smiling.fill"
    case .loading: return "hourglass"
    }
  }
}
