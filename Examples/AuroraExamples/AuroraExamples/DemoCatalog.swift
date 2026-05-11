import SwiftUI

enum Demo: String, CaseIterable, Identifiable {
  case hero
  case styles
  case liveTuning
  case cards
  case burstAction
  case customProfile
  case fakeSiri

  var id: String { rawValue }

  var title: String {
    switch self {
    case .hero: return "Hero"
    case .styles: return "Style comparison"
    case .liveTuning: return "Live tuning"
    case .cards: return ".glow on cards"
    case .burstAction: return "Burst on action"
    case .customProfile: return "Custom Profile"
    case .fakeSiri: return "Fake Siri response"
    }
  }

  var subtitle: String {
    switch self {
    case .hero: return "Full-screen dramatic glow"
    case .styles: return "subtle / standard / dramatic"
    case .liveTuning: return "Tweak every knob live"
    case .cards: return "Modifier on real UI content"
    case .burstAction: return "Fire the burst from a button"
    case .customProfile: return "Build a Profile by hand"
    case .fakeSiri: return "AI-thinking mock screen"
    }
  }

  var systemImage: String {
    switch self {
    case .hero: return "star.fill"
    case .styles: return "rectangle.3.group.fill"
    case .liveTuning: return "slider.horizontal.3"
    case .cards: return "rectangle.stack.fill"
    case .burstAction: return "paperplane.fill"
    case .customProfile: return "waveform.path"
    case .fakeSiri: return "sparkles"
    }
  }
}
