import Foundation

struct MediaAsset: Identifiable, Hashable, Sendable {
    let id: String
    let source: MediaSource
    let url: URL?
    let filename: String
    let mediaType: MediaType
    var availability: AvailabilityState
    var verification: VerificationState

    enum MediaType: String, Sendable {
        case image
        case video
        case unknown
    }
}

enum MediaSource: String, Sendable {
    case photosLibrary
    case filesystem
    case iOSDevice
}

enum AvailabilityState: String, Sendable {
    case local
    case cloudOnly = "cloud-only"
    case downloading
    case unavailable
}

enum VerificationState: String, Sendable {
    case unverified
    case verified
    case failed
}
