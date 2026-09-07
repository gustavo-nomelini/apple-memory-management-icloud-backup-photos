import CryptoKit
import Foundation

struct SHA256Hasher: Sendable {
    func hash(fileAt url: URL) throws -> String {
        let data = try Data(contentsOf: url, options: [.mappedIfSafe])
        return SHA256.hash(data: data)
            .map { String(format: "%02x", $0) }
            .joined()
    }
}
