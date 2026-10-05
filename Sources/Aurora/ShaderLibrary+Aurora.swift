import SwiftUI

extension ShaderLibrary {
  /// Aurora's shaders, precompiled for each platform by `Scripts/build_metallibs.sh`.
  /// Command-line SwiftPM can't compile Metal, so the package has no default library to load.
  /// Without its bundle the glow draws nothing; it never stops the app.
  static let aurora: ShaderLibrary = auroraLibraryURL.map { ShaderLibrary(url: $0) } ?? .default

  static var auroraLibraryURL: URL? {
    #if os(macOS) || targetEnvironment(macCatalyst)
    let name = "AuroraMacOS"
    #elseif targetEnvironment(simulator)
    let name = "AuroraiOSSimulator"
    #else
    let name = "AuroraiOS"
    #endif
    return Bundle.aurora?.url(forResource: name, withExtension: "metallib", subdirectory: "Metallibs")
  }
}

private final class AuroraBundleToken {}

extension Bundle {
  /// Aurora's resource bundle. SwiftPM's generated `Bundle.module` looks only beside the app's executable
  /// and in the build folder, and stops the app when both are missing, but a signed macOS app keeps its
  /// bundles in Contents/Resources. This looks there too, and returns nil instead of crashing.
  static let aurora: Bundle? = {
    let name = "Aurora_Aurora.bundle"
    let code = Bundle(for: AuroraBundleToken.self)
    let places = [Bundle.main.resourceURL, Bundle.main.bundleURL, code.resourceURL, code.bundleURL,
                  code.bundleURL.deletingLastPathComponent()]
    return places.lazy.compactMap { $0.flatMap { Bundle(url: $0.appendingPathComponent(name)) } }.first
  }()
}
