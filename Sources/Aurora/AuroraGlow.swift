import SwiftUI

/// Apple-Intelligence-inspired glow ring rendered by a single Metal
/// fragment shader.
///
/// ## Use
/// ```swift
/// AuroraGlow(.standard).ignoresSafeArea()
/// ```
///
/// ## Style
///
/// `Style` picks one of three pre-tuned looks; each maps to a different
/// set of shader uniforms covering burst amplitude, anchor speed, flame
/// strength, decay rate, and steady-state baseline. Pick by feel:
///
/// - `.subtle`    — gentle steady-state, soft intro, minimal flames
/// - `.standard`  — recommended default; moderate burst, restrained flames
/// - `.dramatic`  — energetic intro, big flames lapping inward; closest to
///                  the Apple Intelligence first-launch animation
///
/// ## Burst
///
/// The shader runs a "burst" envelope at intro: a damped-cosine bounce
/// in the colour anchors, a brightness pop, and bigger flame tongues.
/// It happens automatically on appear (unless `burstsOnAppear` is
/// `false`) and can be re-fired any time through a `Burster`.
///
/// ```swift
/// @State private var burster = AuroraGlow.Burster()
/// AuroraGlow(.standard, burster: burster)
/// Button("Burst again") { burster.fire() }
/// ```
///
/// ## Parameters
/// - `style`: a `Style` preset selecting the burst feel.
/// - `cornerRadius`: outer rounded-rect radius. Default `55`.
/// - `borderWidth`: width of the sharp inner ring. Default `6`.
/// - `glowSize`: outer aura extent in points. Default `28`.
/// - `speed`: baseline anchor animation rate. Default `0.12`. The burst
///   envelope scales this on top.
/// - `burstsOnAppear`: trigger an initial burst when mounted. Default `true`.
/// - `burster`: optional `Burster` for re-firing the burst from outside.
///
/// ## Platform
/// iOS 17+.
public struct AuroraGlow: View {

  // MARK: - Style

  /// Pre-tuned variant of the animation. Each style maps to a fixed
  /// `Profile` that gets handed to the shader. Pick by feel — see the
  /// component-level doc comment for guidance.
  public enum Style: String, CaseIterable, Hashable, Sendable {
    case subtle
    case standard
    case dramatic

    public var profile: Profile {
      switch self {
      case .subtle:
        return Profile(
          anchorAmpBoost: 0.22,
          anchorSpeedBoost: 1.4,
          flameAmpBoost: 1.2,
          brightnessPop: 0.18,
          decayRate: 1.4,
          flameBaseline: 0.30
        )
      case .standard:
        return Profile(
          anchorAmpBoost: 0.38,
          anchorSpeedBoost: 2.2,
          flameAmpBoost: 2.0,
          brightnessPop: 0.32,
          decayRate: 1.6,
          flameBaseline: 0.45
        )
      case .dramatic:
        return Profile(
          anchorAmpBoost: 0.55,
          anchorSpeedBoost: 3.5,
          flameAmpBoost: 4.0,
          brightnessPop: 0.45,
          decayRate: 1.5,
          flameBaseline: 0.55
        )
      }
    }
  }

  /// The numeric knobs that drive the shader. A `Style` is a named
  /// preset; a `Profile` is the actual values that get sent to the
  /// shader's two `float4` uniforms. Build one by hand to dial in a
  /// custom feel without picking one of the presets.
  public struct Profile: Sendable, Equatable {
    /// Damped-cosine amplitude added to anchor amplitude at burst start.
    /// Anchors visibly bounce outward and back. Higher = bigger bounce.
    public var anchorAmpBoost: Float

    /// Exponential boost added to anchor animation speed at burst start.
    /// Higher = faster colour churn during the intro.
    public var anchorSpeedBoost: Float

    /// Exponential boost added to the flame overlay's amplitude. Higher
    /// = bigger inward-reaching flame tongues during burst.
    public var flameAmpBoost: Float

    /// Exponential brightness pop applied uniformly at burst start.
    public var brightnessPop: Float

    /// Decay rate of all envelopes (1 / seconds). Higher = settles faster.
    public var decayRate: Float

    /// Flame overlay amplitude in steady state. Even at rest, flames
    /// remain at this fraction so the boundary has organic life.
    public var flameBaseline: Float

    public init(
      anchorAmpBoost: Float,
      anchorSpeedBoost: Float,
      flameAmpBoost: Float,
      brightnessPop: Float,
      decayRate: Float,
      flameBaseline: Float
    ) {
      self.anchorAmpBoost = anchorAmpBoost
      self.anchorSpeedBoost = anchorSpeedBoost
      self.flameAmpBoost = flameAmpBoost
      self.brightnessPop = brightnessPop
      self.decayRate = decayRate
      self.flameBaseline = flameBaseline
    }
  }

  // MARK: - Burster

  /// Drives the burst-restart envelope from outside the view. Hold one
  /// as `@State` (or anywhere with a stable identity) and pass it to
  /// `AuroraGlow`. Call `fire()` to re-run the intro animation from `t = 0`.
  ///
  /// ```swift
  /// @State private var burster = AuroraGlow.Burster()
  /// AuroraGlow(.standard, burster: burster)
  /// Button("Burst again") { burster.fire() }
  /// ```
  ///
  /// `lastFiredAt` is the timestamp of the most recent `fire()`; the
  /// view observes it and re-fires the burst envelope when it changes.
  @Observable
  public final class Burster {
    public private(set) var lastFiredAt: Date?

    public init() {
      self.lastFiredAt = nil
    }

    public func fire() {
      lastFiredAt = Date()
    }
  }

  // MARK: - Storage

  /// The actual numeric tuning sent to the shader. Derived from a
  /// `Style` preset via `init(_:)`, or supplied directly via
  /// `init(profile:)`.
  public var profile: Profile

  /// Outer rounded-rect radius. Default `55`.
  public var cornerRadius: CGFloat = 55

  /// Width of the sharp inner ring. Default `6`.
  public var borderWidth: CGFloat = 6

  /// Outer aura extent in points. Default `28`.
  public var glowSize: CGFloat = 28

  /// Baseline anchor animation rate. The burst envelope scales this
  /// on top. Default `0.12`.
  public var speed: Double = 0.12

  /// Whether to trigger a burst when the view first appears. Default `true`.
  public var burstsOnAppear: Bool = true

  /// Optional external controller. Call `burster.fire()` from anywhere
  /// (button taps, TCA effects, scroll callbacks) to re-fire the burst
  /// envelope without faking `@State` changes.
  public var burster: Burster?

  // MARK: - Initializers

  /// Build a glow from one of the named presets.
  ///
  /// ```swift
  /// AuroraGlow(.standard)
  ///   .cornerRadius(24)
  ///   .glowSize(18)
  /// ```
  public init(_ style: Style = .standard) {
    self.profile = style.profile
  }

  /// Build a glow from a hand-tuned `Profile`. Use this when none of
  /// the presets feel right.
  public init(profile: Profile) {
    self.profile = profile
  }

  // MARK: - Modifiers

  /// Override the outer rounded-rect radius.
  public func cornerRadius(_ value: CGFloat) -> Self {
    var copy = self
    copy.cornerRadius = value
    return copy
  }

  /// Override the inner ring width.
  public func borderWidth(_ value: CGFloat) -> Self {
    var copy = self
    copy.borderWidth = value
    return copy
  }

  /// Override the outer aura extent.
  public func glowSize(_ value: CGFloat) -> Self {
    var copy = self
    copy.glowSize = value
    return copy
  }

  /// Override the baseline animation rate.
  public func speed(_ value: Double) -> Self {
    var copy = self
    copy.speed = value
    return copy
  }

  /// Disable the automatic burst on appear.
  public func burstsOnAppear(_ value: Bool) -> Self {
    var copy = self
    copy.burstsOnAppear = value
    return copy
  }

  /// Attach a `Burster` so the burst envelope can be re-fired from
  /// outside the view.
  public func burster(_ value: Burster?) -> Self {
    var copy = self
    copy.burster = value
    return copy
  }

  // MARK: - Internal state

  @State private var startDate = Date()
  @State private var burstStartDate: Date? = nil

  public var body: some View {
    GeometryReader { proxy in
      TimelineView(.animation) { context in
        glowRect(in: proxy.size, at: context.date)
      }
    }
    .compositingGroup()
    .allowsHitTesting(false)
    .accessibilityHidden(true)
    .onAppear {
      if burstsOnAppear { burstStartDate = Date() }
    }
    .onChange(of: burster?.lastFiredAt) { _, newValue in
      if let newValue { burstStartDate = newValue }
    }
  }

  private func glowRect(in size: CGSize, at now: Date) -> some View {
    let elapsed = now.timeIntervalSince(startDate)
    let burstElapsed: Double = burstStartDate.map {
      now.timeIntervalSince($0)
    } ?? -1.0
    let t = profile
    return Rectangle()
      .colorEffect(
        ShaderLibrary.bundle(.module).auroraGlow(
          .float2(size),
          .float(elapsed * speed),
          .float(cornerRadius),
          .float(borderWidth),
          .float(glowSize),
          .float(burstElapsed),
          .float4(
            CGFloat(t.anchorAmpBoost),
            CGFloat(t.anchorSpeedBoost),
            CGFloat(t.flameAmpBoost),
            CGFloat(t.brightnessPop)
          ),
          .float4(
            CGFloat(t.decayRate),
            CGFloat(t.flameBaseline),
            0.0,
            0.0
          )
        )
      )
  }
}

#Preview("Subtle") {
  ZStack {
    Color.black.ignoresSafeArea()
    AuroraGlow(.subtle).ignoresSafeArea()
  }
}

#Preview("Standard") {
  ZStack {
    Color.black.ignoresSafeArea()
    AuroraGlow(.standard).ignoresSafeArea()
  }
}

#Preview("Dramatic") {
  ZStack {
    Color.black.ignoresSafeArea()
    AuroraGlow(.dramatic).ignoresSafeArea()
  }
}

#Preview("Inset card · standard") {
  ZStack {
    Color.black.ignoresSafeArea()
    AuroraGlow(.standard)
      .cornerRadius(24)
      .borderWidth(4)
      .glowSize(18)
      .frame(width: 280, height: 360)
  }
}
