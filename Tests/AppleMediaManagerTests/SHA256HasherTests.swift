import Foundation
import Testing
@testable import AppleMediaManager

struct SHA256HasherTests {
    @Test
    func hashesFileContents() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        let fileURL = directory.appendingPathComponent("fixture.txt")
        try Data("hello".utf8).write(to: fileURL)

        let hash = try SHA256Hasher().hash(fileAt: fileURL)

        #expect(hash == "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824")
    }
}
