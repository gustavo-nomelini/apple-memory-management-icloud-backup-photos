import Foundation

protocol MediaSourceAdapter: Sendable {
    var source: MediaSource { get }
    func discoverAssets() async throws -> [MediaAsset]
}

struct FilesystemSourceAdapter: MediaSourceAdapter {
    let source: MediaSource = .filesystem
    let rootURL: URL

    func discoverAssets() async throws -> [MediaAsset] {
        let keys: Set<URLResourceKey> = [.isRegularFileKey, .contentTypeKey]
        let urls = FileManager.default.enumerator(
            at: rootURL,
            includingPropertiesForKeys: Array(keys),
            options: [.skipsHiddenFiles]
        )?.compactMap { $0 as? URL } ?? []

        return try urls.compactMap { url in
            let values = try url.resourceValues(forKeys: keys)
            guard values.isRegularFile == true else { return nil }

            return MediaAsset(
                id: url.standardizedFileURL.path,
                source: .filesystem,
                url: url,
                filename: url.lastPathComponent,
                mediaType: Self.mediaType(for: values.contentType?.identifier),
                availability: .local,
                verification: .unverified
            )
        }
    }

    private static func mediaType(for identifier: String?) -> MediaAsset.MediaType {
        guard let identifier else { return .unknown }
        if identifier.hasPrefix("public.image") { return .image }
        if identifier.hasPrefix("public.movie") || identifier.hasPrefix("public.video") {
            return .video
        }
        return .unknown
    }
}

struct PhotosLibrarySourceAdapter: MediaSourceAdapter {
    let source: MediaSource = .photosLibrary

    func discoverAssets() async throws -> [MediaAsset] {
        // Photos framework integration belongs here. Keep discovery explicit
        // until permissions and the supported Photos API are wired in.
        return []
    }
}

struct IOSDeviceSourceAdapter: MediaSourceAdapter {
    let source: MediaSource = .iOSDevice

    func discoverAssets() async throws -> [MediaAsset] {
        // Device discovery requires a separate integration and user permission.
        return []
    }
}
