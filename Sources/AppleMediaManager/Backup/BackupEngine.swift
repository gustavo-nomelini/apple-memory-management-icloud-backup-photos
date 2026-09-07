import Foundation

struct BackupEngine: Sendable {
    enum BackupError: Error {
        case sourceUnavailable
        case destinationUnavailable
        case destinationFileExists(URL)
        case verificationFailed(URL)
    }

    func backup(_ asset: MediaAsset, to destination: URL) throws -> URL {
        guard let sourceURL = asset.url else {
            throw BackupError.sourceUnavailable
        }

        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: destination.path, isDirectory: &isDirectory),
              isDirectory.boolValue else {
            throw BackupError.destinationUnavailable
        }

        let targetURL = destination.appendingPathComponent(asset.filename)
        guard !FileManager.default.fileExists(atPath: targetURL.path) else {
            throw BackupError.destinationFileExists(targetURL)
        }

        let sourceHash = try SHA256Hasher().hash(fileAt: sourceURL)
        let temporaryURL = destination.appendingPathComponent(".\(UUID().uuidString).partial")
        try FileManager.default.copyItem(at: sourceURL, to: temporaryURL)
        try FileManager.default.moveItem(at: temporaryURL, to: targetURL)

        guard try SHA256Hasher().hash(fileAt: targetURL) == sourceHash else {
            try? FileManager.default.removeItem(at: targetURL)
            throw BackupError.verificationFailed(targetURL)
        }

        return targetURL
    }
}
