import Foundation
import Testing

@testable import Aurora

@Suite("AuroraGlow.Style → Profile")
struct StyleProfileTests {

  @Test func subtleProfileMatchesPresetTable() {
    let p = AuroraGlow.Style.subtle.profile
    #expect(p.anchorAmpBoost == 0.22)
    #expect(p.anchorSpeedBoost == 1.4)
    #expect(p.flameAmpBoost == 1.2)
    #expect(p.brightnessPop == 0.18)
    #expect(p.decayRate == 1.4)
    #expect(p.flameBaseline == 0.30)
  }

  @Test func standardProfileMatchesPresetTable() {
    let p = AuroraGlow.Style.standard.profile
    #expect(p.anchorAmpBoost == 0.38)
    #expect(p.flameAmpBoost == 2.0)
    #expect(p.flameBaseline == 0.45)
  }

  @Test func presetsAreOrderedByLoudness() {
    let subtle = AuroraGlow.Style.subtle.profile
    let standard = AuroraGlow.Style.standard.profile
    let dramatic = AuroraGlow.Style.dramatic.profile

    #expect(subtle.anchorAmpBoost < standard.anchorAmpBoost)
    #expect(standard.anchorAmpBoost < dramatic.anchorAmpBoost)

    #expect(subtle.flameAmpBoost < standard.flameAmpBoost)
    #expect(standard.flameAmpBoost < dramatic.flameAmpBoost)
  }
}

@MainActor
@Suite("AuroraGlow.Burster")
struct BursterTests {

  @Test func freshBursterHasNotFired() {
    let burster = AuroraGlow.Burster()
    #expect(burster.lastFiredAt == nil)
  }

  @Test func fireRecordsATimestamp() {
    let burster = AuroraGlow.Burster()
    burster.fire()
    #expect(burster.lastFiredAt != nil)
  }

  @Test func eachFireAdvancesTheTimestamp() async throws {
    let burster = AuroraGlow.Burster()
    burster.fire()
    let first = try #require(burster.lastFiredAt)
    try await Task.sleep(for: .milliseconds(5))
    burster.fire()
    let second = try #require(burster.lastFiredAt)
    #expect(first < second)
  }
}

@Suite("AuroraGlow init")
struct InitTests {

  @Test func styleInitDerivesProfile() {
    let glow = AuroraGlow(.dramatic)
    #expect(glow.profile == AuroraGlow.Style.dramatic.profile)
  }

  @Test func profileInitKeepsCustomProfile() {
    let custom = AuroraGlow.Profile(
      anchorAmpBoost: 0.5,
      anchorSpeedBoost: 2.5,
      flameAmpBoost: 3.0,
      brightnessPop: 0.4,
      decayRate: 1.5,
      flameBaseline: 0.5
    )
    let glow = AuroraGlow(profile: custom)
    #expect(glow.profile == custom)
  }

  @Test func defaultsMatchDocumentedValues() {
    let glow = AuroraGlow()
    #expect(glow.cornerRadius == 55)
    #expect(glow.borderWidth == 6)
    #expect(glow.glowSize == 28)
    #expect(glow.speed == 0.12)
    #expect(glow.burstsOnAppear == true)
    #expect(glow.burster == nil)
  }

  @Test func chainableModifiersReturnUpdatedCopy() {
    let glow = AuroraGlow(.standard)
      .cornerRadius(24)
      .borderWidth(4)
      .glowSize(18)
      .speed(0.2)
      .burstsOnAppear(false)
    #expect(glow.cornerRadius == 24)
    #expect(glow.borderWidth == 4)
    #expect(glow.glowSize == 18)
    #expect(glow.speed == 0.2)
    #expect(glow.burstsOnAppear == false)
  }
}
