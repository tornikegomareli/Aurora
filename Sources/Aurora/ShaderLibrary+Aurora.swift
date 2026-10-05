import SwiftUI

extension ShaderLibrary {
  /// Aurora's shaders, precompiled for each platform by `Scripts/build_metallibs.sh`.
  /// Command-line SwiftPM can't compile Metal, so `.bundle(.module)` would find no library there.
  static let aurora: ShaderLibrary = auroraLibraryURL.map { ShaderLibrary(url: $0) } ?? .bundle(.module)

  static var auroraLibraryURL: URL? {
    #if os(macOS) || targetEnvironment(macCatalyst)
    let name = "AuroraMacOS"
    #elseif targetEnvironment(simulator)
    let name = "AuroraiOSSimulator"
    #else
    let name = "AuroraiOS"
    #endif
    return Bundle.module.url(forResource: name, withExtension: "metallib", subdirectory: "Metallibs")
  }
}
