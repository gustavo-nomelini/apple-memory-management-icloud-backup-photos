import Foundation

@MainActor
final class MediaScanner {
    private(set) var assets: [MediaAsset] = []
    private(set) var isScanning = false
    private(set) var lastError: String?

    func scan(using adapters: [any MediaSourceAdapter]) async {
        isScanning = true
        lastError = nil
        defer { isScanning = false }

        do {
            var discovered: [MediaAsset] = []
            for adapter in adapters {
                discovered.append(contentsOf: try await adapter.discoverAssets())
            }
            assets = discovered.sorted { $0.filename.localizedStandardCompare($1.filename) == .orderedAscending }
        } catch {
            lastError = error.localizedDescription
        }
    }

    func reset() {
        assets = []
        lastError = nil
    }
}
