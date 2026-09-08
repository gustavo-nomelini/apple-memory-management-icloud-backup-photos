import SwiftUI

struct ContentView: View {
    let environment: AppEnvironment
    @State private var scanTask: Task<Void, Never>?

    var body: some View {
        VStack(spacing: 16) {
            header

            if environment.scanner.isScanning {
                ProgressView("Scanning your Pictures folder...")
            } else if let error = environment.scanner.lastError {
                Label(error, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            } else if environment.scanner.assets.isEmpty {
                Text("No media has been scanned yet.")
                    .foregroundStyle(.secondary)
            } else {
                scanSummary
                assetList
            }

            Button(environment.scanner.isScanning ? "Scanning..." : "Scan Pictures folder") {
                startScan()
            }
            .buttonStyle(.borderedProminent)
            .disabled(environment.scanner.isScanning)
        }
        .padding(32)
        .frame(minWidth: 520, minHeight: 360)
        .onDisappear {
            scanTask?.cancel()
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("Apple Media Manager")
                .font(.title)

            Text("Inspect local media and prepare a verified backup.")
                .foregroundStyle(.secondary)
        }
    }

    private var scanSummary: some View {
        Text("\(environment.scanner.assets.count) media file(s) found")
            .font(.headline)
    }

    private var assetList: some View {
        List(environment.scanner.assets) { asset in
            Label(asset.filename, systemImage: icon(for: asset.mediaType))
        }
        .frame(maxHeight: 180)
    }

    private func startScan() {
        let picturesURL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Pictures", isDirectory: true)
        let adapter = FilesystemSourceAdapter(rootURL: picturesURL)

        scanTask = Task {
            await environment.scanner.scan(using: [adapter])
        }
    }

    private func icon(for mediaType: MediaAsset.MediaType) -> String {
        switch mediaType {
        case .image:
            return "photo"
        case .video:
            return "video"
        case .unknown:
            return "doc"
        }
    }
}
