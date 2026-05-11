// Apple-Intelligence-style multi-colour animated glow with burst physics,
// noise-driven flame edges, and per-style tunings.
//
// Reverse-engineered from `SUICEdgeLightMaskMetalLayer` /
// `IntelligentLightFrag` / `IntelligentLightNoiseFrag` inside
// `SiriUICore.framework/archive.metallib` on iOS 26.4.2. None of Apple's
// original code is copied — only the algorithm is reproduced.
//
// ## Technique
//
// 1. **Metaball-style colour blend** over 11 animated anchor points.
//    Four-stop palette (purple / pink / orange / cyan) iterated in a
//    fixed cycle.
//
// 2. **SDF warped by 3D gradient noise, with a clean-ring floor.** The
//    rounded-rect SDF is deformed by the noise field so wave fronts
//    visibly carve against the dark interior — this is the technique
//    Apple uses and it's why the boundary reads as a real wave rather
//    than a painted-on glow. The catch with naive warping is that noise
//    pushing outward thins the band at that pixel and can starve a
//    whole corner during the burst. Fix: take `min(abs(clean), abs(warped))`
//    so the warped distance can only ever *extend* the band, never
//    shrink it below the clean ring's width.
//
// 3. **Burst envelope** drives bounce, anchor speed, brightness pop,
//    flame amplitude, and noise scroll speed. All values are
//    parameterised by `tuningA` / `tuningB` uniforms so different
//    Swift-side styles (`subtle`, `standard`, `dramatic`) feel right
//    without recompiling the shader.

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>

using namespace metal;

// MARK: - Palette

constant half3 kColorBase   = half3(0.000h, 0.588h, 1.000h);
constant half3 kColorPurple = half3(0.983h, 0.392h, 1.000h);
constant half3 kColorPink   = half3(1.000h, 0.145h, 0.333h);
constant half3 kColorOrange = half3(1.000h, 0.577h, 0.000h);
constant half3 kColorCyan   = half3(0.000h, 0.588h, 1.000h);

constant half3 kAnchorColors[11] = {
  kColorPurple, kColorPink, kColorOrange, kColorCyan, kColorOrange,
  kColorPurple, kColorPink, kColorCyan, kColorPink, kColorOrange, kColorPurple,
};

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

// MARK: - Burst envelopes (style-parameterised)

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

// Flame overlay amplitude during burst. Always >= waveBaseline so flames
// exist in steady state at a low level too.
inline float burstFlameAmp(float t, float ampBoost, float baseline, float decay) {
  if (t < 0.0 || t >= kBurstDuration) return baseline;
  return baseline + ampBoost * exp(-t * decay);
}

inline float burstNoiseSpeed(float t, float decay) {
  if (t < 0.0 || t >= kBurstDuration) return 1.0;
  return 1.0 + 3.0 * exp(-t * (decay + 0.1));
}

// MARK: - 3D gradient noise + FBM (canonical Inigo-Quilez-style;
// rewritten from scratch — Apple uses a baked texture instead).

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

// MARK: - Geometry helpers

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

// MARK: - Colour blend

inline half3 intelligenceLightColor(
  float2 xyPos, float2 size,
  float time, float burstT,
  float ampBoost, float speedBoost, float decay,
  float reach, float power
) {
  half3 color = kColorBase;
  for (int i = 0; i < 11; ++i) {
    float2 a = anchorPosition(i, time, burstT, ampBoost, speedBoost, decay, size);
    float d = length(a - xyPos) / reach;
    float fall = clamp(1.0 - d, 0.0, 1.0);
    float t = fall * fall * (3.0 - 2.0 * fall);
    color = mix(color, kAnchorColors[i], half(t));
  }
  color = min(color, half3(1.0h));

  half  luma = dot(color, half3(0.213h, 0.716h, 0.072h));
  half  satFactor = half(1.0 + power * 0.2);
  color = mix(half3(luma), color, satFactor);

  return color;
}

// MARK: - Entry point
//
// tuningA = (anchorAmpBoost, anchorSpeedBoost, flameAmpBoost, brightnessPop)
// tuningB = (decayRate,      flameBaseline,    [reserved],    [reserved])

[[ stitchable ]] half4 auroraGlow(
  float2 position,
  half4 color,
  float2 size,
  float time,
  float cornerRadius,
  float borderWidth,
  float glowSize,
  float burstElapsed,
  float4 tuningA,
  float4 tuningB
) {
  float anchorAmpBoost   = tuningA.x;
  float anchorSpeedBoost = tuningA.y;
  float flameAmpBoost    = tuningA.z;
  float brightnessPop    = tuningA.w;
  float decayRate        = tuningB.x;
  float flameBaseline    = tuningB.y;

  float2 center = size * 0.5;
  float2 p = position - center;

  // ===== Noise field (drives the wavy edge) =====
  // Faithful to Apple's technique: the edge gets warped *into* the black
  // interior by the noise field, so wave fronts visibly carve against the
  // dark background instead of just being added on top.
  float2 uv = position / max(size.x, size.y);
  float noiseScrollSpeed = 0.30 * burstNoiseSpeed(burstElapsed, decayRate);
  float n  = fbm3D(float3(uv * 2.0, time * noiseScrollSpeed));
  float n2 = gradientNoise3D(float3(uv * 3.6 + float2(11.7, 5.3),
                                    time * noiseScrollSpeed * 0.55));
  float waveValue = n * 0.7 + n2 * 0.35;

  // ===== Warped SDF =====
  // The clean SDF defines the rounded-rect boundary. The warped SDF lets
  // the noise field deform it. We take `min(abs(clean), abs(warped))` so
  // the band width is never *less* than the clean ring — that floor kills
  // the corner-starvation artifact (top-left going to a thin red border)
  // while still letting the warped field *extend* the band inward where
  // the noise pushes outward. Result: lapping wave-into-black look on the
  // outside, full-width clean ring guaranteed on the inside.
  float distRaw = roundedRectSDF(p, center, cornerRadius);
  float flameAmp = burstFlameAmp(burstElapsed, flameAmpBoost, flameBaseline, decayRate);
  float waveAmount = glowSize * flameAmp;
  float distWarped = distRaw + waveValue * waveAmount;
  float absDist = min(abs(distRaw), abs(distWarped));

  // ===== Edge-band mask =====
  float core = smoothstep(borderWidth + 1.0, borderWidth - 1.0, absDist);
  float mid  = smoothstep(glowSize * 0.6,    0.0,                absDist) * 0.55;
  float wide = smoothstep(glowSize * 1.4,    0.0,                absDist) * 0.30;
  float maskIntensity = saturate(core + mid + wide);

  // Subtle per-pixel flicker from the same noise so the boundary
  // shimmers even at rest.
  float flicker = 0.88 + 0.18 * (waveValue * 0.5 + 0.5);
  maskIntensity *= flicker;

  // ===== Colour =====
  float reach = 0.55 * max(size.x, size.y);
  half3 lit = intelligenceLightColor(
    position, size,
    time, burstElapsed,
    anchorAmpBoost, anchorSpeedBoost, decayRate,
    reach, /* power */ 0.0
  );

  lit *= half(0.95 * burstBrightness(burstElapsed, brightnessPop, decayRate));

  return half4(lit * half(maskIntensity), half(maskIntensity));
}
