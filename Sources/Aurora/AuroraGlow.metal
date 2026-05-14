// Apple-Intelligence-style multi-colour animated glow with burst physics,
// noise-driven flame edges, and per-style tunings.
//
// 1. Metaball-style colour blend** over 11 animated anchor points.
//    Four-stop palette (purple / pink / orange / cyan) iterated in a
//    fixed cycle.
//
// 2. SDF warped by 3D gradient noise, with a clean-ring floor. The
//    rounded-rect SDF is deformed by the noise field so wave fronts
//    visibly carve against the dark interior, this is the technique
//    Apple uses and it's why the boundary reads as a real wave rather
//    than a painted-on glow.
//
// 3. Burst envelope drives bounce, anchor speed, brightness pop,
//    flame amplitude, and noise scroll speed. All values are
//    parameterised by `tuningA` / `tuningB` uniforms so different
//    Swift-side styles (`subtle`, `standard`, `dramatic`) feel right
//    without recompiling the shader.

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>

using namespace metal;

// Anchor colors are no longer constants — they come from caller-
// supplied palette uniforms (paletteBase, paletteA..paletteD). The
// 11 anchor positions cycle through the four anchor colours in a
// fixed pattern: a, b, c, d, c, a, b, d, b, c, a.
inline half3 anchorColorAt(int i, half3 a, half3 b, half3 c, half3 d) {
  if (i == 0)  return a;
  if (i == 1)  return b;
  if (i == 2)  return c;
  if (i == 3)  return d;
  if (i == 4)  return c;
  if (i == 5)  return a;
  if (i == 6)  return b;
  if (i == 7)  return d;
  if (i == 8)  return b;
  if (i == 9)  return c;
  return a;
}

constant float2 kAnchorFreq[11] = {
  float2(0.31, 0.27), float2(0.43, 0.19), float2(0.17, 0.37),
  float2(0.29, 0.23), float2(0.41, 0.31), float2(0.19, 0.43),
  float2(0.37, 0.17), float2(0.23, 0.29), float2(0.31, 0.41),
  float2(0.27, 0.19), float2(0.43, 0.37),
};

constant float2 kAnchorPhase[11] = {
  float2(0.0, 1.7), float2(1.3, 0.4), float2(2.1, 2.6),
  float2(0.7, 1.1), float2(2.8, 0.2), float2(1.8, 2.3),
  float2(0.3, 1.5), float2(2.5, 0.8), float2(1.2, 2.0),
  float2(0.5, 1.9), float2(2.7, 0.6),
};

constant float kBurstDuration = 3.5;

inline float burstAmplitude(float t, float ampBoost, float decay) {
  if (t < 0.0 || t >= kBurstDuration) return 1.0;
  float d = exp(-t * decay);
  float wave = cos(t * 6.28318 * 1.3);
  return 1.0 + ampBoost * d * wave;
}

inline float burstSpeed(float t, float speedBoost, float decay) {
  if (t < 0.0 || t >= kBurstDuration) return 1.0;
  return 1.0 + speedBoost * exp(-t * (decay + 0.2));
}

inline float burstBrightness(float t, float pop, float decay) {
  if (t < 0.0 || t >= kBurstDuration) return 1.0;
  return 1.0 + pop * exp(-t * (decay + 1.4));
}

/// Flame overlay amplitude during burst. Always >= waveBaseline so flames
/// exist in steady state at a low level too.
inline float burstFlameAmp(float t, float ampBoost, float baseline, float decay) {
  if (t < 0.0 || t >= kBurstDuration) return baseline;
  return baseline + ampBoost * exp(-t * decay);
}

inline float burstNoiseSpeed(float t, float decay) {
  if (t < 0.0 || t >= kBurstDuration) return 1.0;
  return 1.0 + 3.0 * exp(-t * (decay + 0.1));
}

// Intro envelope (thicknessGrow style): scales the band from invisible
// to full thickness with a tiny overshoot before settling. `duration`
// is the wall time the animation takes. `t < 0` (intro not playing)
// or `t >= duration` (intro finished) return 1.0 so the band renders
// at full size.
inline float introScale(float t, float duration) {
  if (t < 0.0 || t >= duration) return 1.0;
  float p = t / duration;
  float ease = 1.0 - pow(1.0 - p, 3.0);
  float bump = 0.08 * sin(p * 3.14159);
  return ease * (1.0 + bump);
}

// Heartbeat envelope: base growth with damped oscillations on top, so
// the band visibly pulses 2–3 times before settling. The exponential
// decay term reduces the amplitude of each successive pulse.
inline float introScaleHeartbeat(float t, float duration) {
  if (t < 0.0 || t >= duration) return 1.0;
  float p = t / duration;
  float base = 1.0 - pow(1.0 - p, 2.0);
  float pulses = 0.35 * exp(-p * 3.5) * cos(p * 6.28318 * 2.8);
  return clamp(base + pulses, 0.0, 1.5);
}

// Intro envelope (borderFill style): mask that "fills" the perimeter
// from the direction's start edge, sweeping around both ways and
// meeting itself at the opposite side. Uses the angle from the
// rectangle's centre as a proxy for the perimeter position — a fair
// approximation for rounded rects without measuring true arc length.
//   t            — elapsed time since intro started
//   duration     — total intro time
//   startPerimT  — where on the perimeter the fill originates (0..1)
inline float borderFillMask(
  float2 position, float2 size, float startPerimT, float t, float duration
) {
  if (t < 0.0 || t >= duration) return 1.0;

  float2 p = position - size * 0.5;
  float angle = atan2(p.y, p.x);                 // -pi..pi
  float perimT = (angle + 3.14159) * 0.15915494;  // /(2*pi) → 0..1

  // Distance around the loop from the start position (both ways);
  // *2 normalises to 0..1.
  float dist = abs(perimT - startPerimT);
  dist = min(dist, 1.0 - dist) * 2.0;

  float normT = t / duration;
  float softness = 0.08;
  return 1.0 - smoothstep(normT - softness, normT + softness, dist);
}

// Convert a direction vector to its origin's perimeter position. The
// direction points where the wave travels TO, so the perimeter start
// is in the *opposite* direction from the centre.
inline float perimeterStartFromDirection(float2 dir) {
  return (atan2(-dir.y, -dir.x) + 3.14159) * 0.15915494;
}

// Intro wash: a fast semi-transparent pulse that *travels outward*
// from the centre of the frame. Each pixel sees its own short sine
// pulse, delayed by its normalised distance from centre, so the
// effect reads as a wave sweeping across the screen. All three
// parameters are passed in as a uniform so callers can tune the
// feel without recompiling:
//   sweepDuration — seconds for the wave front to reach the corners
//   pulseWidth    — seconds each pixel stays lit as the wave passes
//   peak          — maximum alpha contribution at pulse peak (0..1)
// Linear directional wash: a single travelling wavefront perpendicular
// to `direction` that crosses the rectangle once. Each pixel sees a
// brief sine pulse as the front passes through it. Direction (-1, 0)
// is right-to-left, (0, -1) is bottom-to-top, etc.
//   sweepDuration — seconds for the front to cross the rectangle
//   pulseWidth    — seconds each pixel stays lit as the front passes
//   peak          — max alpha at pulse centre
inline float introWashAlpha(
  float t, float2 position, float2 size, float2 direction,
  float sweepDuration, float pulseWidth, float peak
) {
  if (t < 0.0 || peak <= 0.0) return 0.0;

  float proj = dot(position, direction);
  float minProj = min(0.0, size.x * direction.x) + min(0.0, size.y * direction.y);
  float maxProj = max(0.0, size.x * direction.x) + max(0.0, size.y * direction.y);
  float range = max(maxProj - minProj, 1.0);

  float normT = (proj - minProj) / range;
  float arrival = normT * sweepDuration;
  float localT  = t - arrival;
  if (localT < 0.0 || localT > pulseWidth) return 0.0;

  float u = localT / pulseWidth;
  return peak * sin(u * 3.14159);
}

/// 3D gradient noise + FBM, computed procedurally
inline float3 hash33(float3 p) {
  p = float3(
             dot(p, float3(127.1, 311.7,  74.7)),
             dot(p, float3(269.5, 183.3, 246.1)),
             dot(p, float3(113.5, 271.9, 124.6))
             );
  return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

inline float gradientNoise3D(float3 p) {
  float3 i = floor(p);
  float3 f = fract(p);
  float3 u = f * f * (3.0 - 2.0 * f);
  
  return mix(
             mix(
                 mix(dot(hash33(i + float3(0,0,0)), f - float3(0,0,0)),
                     dot(hash33(i + float3(1,0,0)), f - float3(1,0,0)), u.x),
                 mix(dot(hash33(i + float3(0,1,0)), f - float3(0,1,0)),
                     dot(hash33(i + float3(1,1,0)), f - float3(1,1,0)), u.x),
                 u.y),
             mix(
                 mix(dot(hash33(i + float3(0,0,1)), f - float3(0,0,1)),
                     dot(hash33(i + float3(1,0,1)), f - float3(1,0,1)), u.x),
                 mix(dot(hash33(i + float3(0,1,1)), f - float3(0,1,1)),
                     dot(hash33(i + float3(1,1,1)), f - float3(1,1,1)), u.x),
                 u.y),
             u.z);
}

inline float fbm3D(float3 p) {
  float v = 0.0;
  float a = 0.6;
  v += a * gradientNoise3D(p);
  p *= 2.1;
  a *= 0.55;
  v += a * gradientNoise3D(p);
  return v;
}

inline float roundedRectSDF(float2 p, float2 halfSize, float cornerRadius) {
  float2 q = abs(p) - halfSize + cornerRadius;
  return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - cornerRadius;
}

inline float2 anchorPosition(
                             int i, float time, float burstT,
                             float ampBoost, float speedBoost, float decay,
                             float2 size
                             ) {
  float ampScale   = burstAmplitude(burstT, ampBoost, decay);
  float speedScale = burstSpeed(burstT, speedBoost, decay);
  
  float2 phase = kAnchorPhase[i];
  float2 freq  = kAnchorFreq[i];
  
  float extra = (burstT >= 0.0 && burstT < kBurstDuration)
  ? (1.0 - exp(-burstT * (decay + 0.2))) * 6.28
  : 0.0;
  
  float t = time * speedScale + extra;
  float amp = clamp(0.42 * ampScale, 0.0, 0.48);
  
  float2 norm = float2(
                       0.5 + amp * sin(t * freq.x + phase.x),
                       0.5 + amp * cos(t * freq.y + phase.y)
                       );
  return norm * size;
}

inline half3 intelligenceLightColor(
                                    float2 xyPos, float2 size,
                                    float time, float burstT,
                                    float ampBoost, float speedBoost, float decay,
                                    float reach, float power,
                                    half3 paletteBase,
                                    half3 paletteA, half3 paletteB,
                                    half3 paletteC, half3 paletteD
                                    ) {
  half3 color = paletteBase;
  for (int i = 0; i < 11; ++i) {
    float2 a = anchorPosition(i, time, burstT, ampBoost, speedBoost, decay, size);
    float d = length(a - xyPos) / reach;
    float fall = clamp(1.0 - d, 0.0, 1.0);
    float t = fall * fall * (3.0 - 2.0 * fall);
    color = mix(color, anchorColorAt(i, paletteA, paletteB, paletteC, paletteD), half(t));
  }
  color = min(color, half3(1.0h));
  
  half  luma = dot(color, half3(0.213h, 0.716h, 0.072h));
  half  satFactor = half(1.0 + power * 0.2);
  color = mix(half3(luma), color, satFactor);
  
  return color;
}

/// Uniforms
///   tuningA = (anchorAmpBoost, anchorSpeedBoost, flameAmpBoost, brightnessPop)
///   tuningB = (decayRate,      flameBaseline,    [reserved],    [reserved])
[[ stitchable ]] half4 auroraGlow(
                                  float2 position,
                                  half4 color,
                                  float2 size,
                                  float time,
                                  float cornerRadius,
                                  float borderWidth,
                                  float glowSize,
                                  float burstElapsed,
                                  float introElapsed,
                                  float outroElapsed,
                                  float2 introParams,
                                  float2 outroParams,
                                  float4 tuningA,
                                  float4 tuningB,
                                  float3 washParams,
                                  float2 washDirection,
                                  float3 paletteBase,
                                  float3 paletteA,
                                  float3 paletteB,
                                  float3 paletteC,
                                  float3 paletteD
                                  ) {
  float anchorAmpBoost   = tuningA.x;
  float anchorSpeedBoost = tuningA.y;
  float flameAmpBoost    = tuningA.z;
  float brightnessPop    = tuningA.w;
  float decayRate        = tuningB.x;
  float flameBaseline    = tuningB.y;

  float2 center = size * 0.5;
  float2 p = position - center;

  float introDuration = introParams.x;
  float styleId       = introParams.y;
  bool useBorderFill  = styleId > 0.5 && styleId < 1.5;
  bool useHeartbeat   = styleId > 1.5;

  // Intro style branches:
  //   0 thicknessGrow — band scales from invisible to full size
  //   1 borderFill    — band stays full but masked along the perimeter
  //   2 heartbeat     — thickness pulses 2–3 times before settling
  float introMul;
  if (useBorderFill) {
    introMul = 1.0;
  } else if (useHeartbeat) {
    introMul = introScaleHeartbeat(introElapsed, introDuration);
  } else {
    introMul = introScale(introElapsed, introDuration);
  }

  // Outro fade: when outroElapsed >= 0, the glow is on its way out.
  // shrinkInward (style 1) scales the band thickness toward zero;
  // dissolve (style 0) keeps the band size and fades alpha at the
  // very end via outroAlpha.
  float outroAlpha = 1.0;
  if (outroElapsed >= 0.0) {
    float outroDur     = outroParams.x;
    float outroStyleId = outroParams.y;
    float op = clamp(outroElapsed / max(outroDur, 0.0001), 0.0, 1.0);
    if (outroStyleId > 0.5) {
      introMul *= (1.0 - op);
    } else {
      outroAlpha = 1.0 - op;
    }
  }

  float effectiveBorder = borderWidth * introMul;
  float effectiveGlow   = glowSize   * introMul;

  /// Faithful to Apple's technique the edge gets warped into the black
  /// interior by the noise field, so wave fronts visibly carve against the
  /// dark background instead of just being added on top.
  float2 uv = position / max(size.x, size.y);
  float noiseScrollSpeed = 0.30 * burstNoiseSpeed(burstElapsed, decayRate);
  float n  = fbm3D(float3(uv * 2.0, time * noiseScrollSpeed));
  float n2 = gradientNoise3D(float3(uv * 3.6 + float2(11.7, 5.3),
                                    time * noiseScrollSpeed * 0.55));
  float waveValue = n * 0.7 + n2 * 0.35;

  /// The clean SDF defines the rounded-rect boundary. The warped SDF lets
  /// the noise field deform it. We take `min(abs(clean), abs(warped))` so
  /// the band width is never *less* than the clean ring, that floor kills
  /// the corner-starvation artifact
  /// while still letting the warped field extend the band inward where
  /// the noise pushes outward. in result we get lapping wave-into-black look on the
  /// outside, full-width clean ring guaranteed on the inside.
  float distRaw = roundedRectSDF(p, center, cornerRadius);
  float flameAmp = burstFlameAmp(burstElapsed, flameAmpBoost, flameBaseline, decayRate);
  float waveAmount = effectiveGlow * flameAmp;
  float distWarped = distRaw + waveValue * waveAmount;
  float absDist = min(abs(distRaw), abs(distWarped));

  // edge band mask
  float core = smoothstep(effectiveBorder + 1.0, effectiveBorder - 1.0, absDist);
  float mid  = smoothstep(effectiveGlow * 0.6,   0.0,                   absDist) * 0.55;
  float wide = smoothstep(effectiveGlow * 1.4,   0.0,                   absDist) * 0.30;
  float maskIntensity = saturate(core + mid + wide);

  // subtle per-pixel flicker from the same noise so the boundary
  // shimmers even at rest
  float flicker = 0.88 + 0.18 * (waveValue * 0.5 + 0.5);
  maskIntensity *= flicker;

  // borderFill style masks the edge band so it appears to draw itself
  // around the perimeter from the direction's start edge. No-op when
  // introStyle == thicknessGrow.
  if (useBorderFill) {
    float startPerimT = perimeterStartFromDirection(washDirection);
    float fillMask = borderFillMask(position, size, startPerimT, introElapsed, introDuration);
    maskIntensity *= fillMask;
  }

  // Travelling intro wash: each pixel sees its own brief pulse, delayed
  // by distance from the frame's centre. Combined with noise modulation
  // for grain. Max-blended with the edge mask so the edge ring stays at
  // full intensity; the rest of the screen only lights up while the
  // wave passes through it.
  float washAlpha = introWashAlpha(
    introElapsed, position, size, washDirection,
    washParams.x, washParams.y, washParams.z
  );
  float washIntensity = washAlpha * (0.55 + 0.45 * (waveValue * 0.5 + 0.5));
  maskIntensity = max(maskIntensity, washIntensity);
  
  float reach = 0.55 * max(size.x, size.y);
  half3 lit = intelligenceLightColor(
                                     position, size,
                                     time, burstElapsed,
                                     anchorAmpBoost, anchorSpeedBoost, decayRate,
                                     reach, 0.0,
                                     half3(paletteBase),
                                     half3(paletteA), half3(paletteB),
                                     half3(paletteC), half3(paletteD)
                                     );
  
  lit *= half(0.95 * burstBrightness(burstElapsed, brightnessPop, decayRate));

  // While the wash is active, lift saturation by extrapolating away
  // from luma. This mirrors what Apple's `SaturatedV1Frag` does with
  // its `mix(luma, color, 1.5)` trick — pushes the colours past the
  // gray axis so the pulse reads as more vivid than the steady-state
  // ring. Settles back to neutral once wash returns to 0.
  half washLuma = dot(lit, half3(0.213h, 0.716h, 0.072h));
  half satFactor = half(1.0) + half(washAlpha) * half(0.5);
  lit = mix(half3(washLuma), lit, satFactor);

  maskIntensity *= outroAlpha;
  return half4(lit * half(maskIntensity), half(maskIntensity));
}

/// Standalone metaball colour field for filling arbitrary shapes
/// (glyphs, paths, masks) with the same animated palette used by the
/// glow ring. Strips out all SDF, edge band, burst envelope, intro,
/// outro, and wash logic — only the multi-anchor colour blend
/// remains, so SwiftUI compositing handles the alpha mask
/// (anti-aliased glyph edges from `Text.foregroundStyle`, fills from
/// `Shape.fill`, etc.). Returns RGB with alpha 1.0.
[[ stitchable ]] half4 auroraShimmer(
  float2 position,
  float2 size,
  float time,
  float3 paletteBase,
  float3 paletteA,
  float3 paletteB,
  float3 paletteC,
  float3 paletteD
) {
  float reach = 0.55 * max(size.x, size.y);
  half3 lit = intelligenceLightColor(
    position, size,
    time, -1.0,
    0.0, 0.0, 1.0,
    reach, 0.0,
    half3(paletteBase),
    half3(paletteA), half3(paletteB),
    half3(paletteC), half3(paletteD)
  );
  return half4(lit, 1.0h);
}
