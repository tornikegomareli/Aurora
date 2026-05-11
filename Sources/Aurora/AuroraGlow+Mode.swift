import Foundation

extension AuroraGlow {
  /// Which shader entry point the View renders. `.edgeRing` is the
  /// Apple-Intelligence-style animated ring with burst + intro
  /// envelopes. The other cases isolate the static / full-screen
  /// variants Apple ships alongside it in `SiriUICore.framework`, so
  /// they can be eyeballed side-by-side.
  public enum Mode: String, CaseIterable, Hashable, Sendable {
    /// 11-anchor animated edge ring with intro + burst envelopes.
    /// Default. Honors `cornerRadius`, `borderWidth`, `glowSize`,
    /// `speed`, `burstsOnAppear`, `introOnAppear`, and `burster`.
    case edgeRing

    /// Vivid, static, full-screen 6-anchor metaball blend with
    /// saturation pushed past 1.0. Reproduces the technique behind
    /// Apple's `IntelligentLightSaturatedV1Frag`.
    case saturated

    /// Contrast-shaped static 6-anchor blend (knocks out lows, caps
    /// highs). Reproduces the technique behind Apple's
    /// `IntelligentLightBuddyFrag`.
    case buddy

    /// Animated full-screen noise-modulated colour wash. Reproduces
    /// the technique behind Apple's `IntelligentLightNoiseFullFrag`
    /// crossed with the metaball blend.
    case noiseField
  }
}
