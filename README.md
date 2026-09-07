# Apple Media Manager & Backup Tool

A macOS utility for organizing, inspecting, verifying, and backing up
photo and video libraries from **Apple Photos**, **iCloud Photos**, and
connected **iOS devices**.

The project is designed around one principle:

> **Never modify or delete user media unless the user explicitly
> approves the operation.**

## ✨ Overview

Apple Media Manager aims to make local media storage and backup state
easy to understand while providing a safe, verifiable backup workflow.

The planned workflow is:

1.  Discover media from the macOS Photos library and connected iOS
    devices.
2.  Determine whether each asset is stored locally, cloud-only,
    downloading, or unavailable.
3.  Detect exact duplicates and optionally identify visually similar
    media.
4.  Back up eligible full-resolution assets to a user-selected external
    volume.
5.  Verify every completed backup using file metadata and SHA-256
    checksums.
6.  Report progress, errors, duplicates, verification results, and
    storage savings.

> **Project status:** This repository is currently an initial Xcode
> project scaffold. Core media scanning, iCloud verification, duplicate
> detection, and the backup pipeline are still being implemented.

------------------------------------------------------------------------

## 🎯 Goals

-   Reliable and repeatable backups of Apple media.
-   Clear visibility into local and iCloud media availability.
-   Exact duplicate detection using cryptographic hashes.
-   Optional visual-similarity detection using perceptual hashing.
-   Support for external drives formatted as **APFS** or **exFAT**.
-   Resumable backups that survive interruptions.
-   Destination verification before a backup is considered complete.
-   Clear progress, cancellation, retry, and error reporting.
-   Explicit confirmation for destructive or potentially irreversible
    actions.
-   Privacy-conscious logging that avoids exposing media contents or
    account secrets.

## 🚫 Non-goals

This project is **not** intended to:

-   Replace iCloud Photos.
-   Act as an iCloud synchronization service.
-   Automatically delete originals.
-   Automatically delete Photos library records or iCloud assets.
-   Assume a filename, path, or file size proves two files are
    identical.
-   Assume a connected iOS device is continuously available or writable.
-   Treat a thumbnail or preview as the full-resolution original.

------------------------------------------------------------------------

## 🧠 Core Architecture

The application should be organized into small, testable components with
explicit responsibilities.

### Source adapters

Responsible for discovering assets from:

-   macOS Photos
-   Filesystem sources
-   Connected iOS devices

### Asset model

Represents each media asset with information such as:

-   Stable internal identity
-   Source
-   Location
-   Filename
-   Media type
-   Availability state
-   Metadata
-   Verification state

Suggested availability states:

  -----------------------------------------------------------------------
  State                               Meaning
  ----------------------------------- -----------------------------------
  `local`                             The complete original is available
                                      locally.

  `cloud-only`                        The original is stored in iCloud
                                      but is not currently local.

  `downloading`                       The original is being downloaded.

  `verified`                          The local copy has passed integrity
                                      checks.

  `unavailable`                       The source or asset could not be
                                      reached or inspected.
  -----------------------------------------------------------------------

### Scanner

Responsible for:

-   Media discovery
-   Incremental change detection
-   Availability inspection
-   Source validation

### Hasher

Provides:

-   Metadata-based candidate grouping
-   SHA-256 hashing for exact duplicates
-   Optional pHash analysis for visual similarity

### Duplicate index

Stores and explains duplicate candidates, including:

-   Files involved
-   Detection algorithm
-   Confidence
-   Reason for the match

Perceptual similarity is **advisory only**. A pHash match must never be
treated as proof that two files are identical.

### Backup engine

Responsible for:

-   Copying media
-   Resuming interrupted copies
-   Avoiding unintended overwrites
-   Atomic finalization
-   Destination verification
-   Recording successful and failed operations

### Job coordinator

Coordinates:

-   Cancellation
-   Retries
-   Progress
-   Structured errors
-   Long-running operations

### Presentation / CLI layer

Provides:

-   Human-readable application output
-   Progress information
-   Error summaries
-   Machine-readable progress events for automation

------------------------------------------------------------------------

## 📁 Project Structure

The following structure is the recommended organization for the project
as the implementation grows:

``` text
apple-memory-management/
├── apple-memory-management.xcodeproj/
│   └── project configuration
│
├── Sources/
│   ├── App/
│   │   ├── AppleMediaManagerApp.swift
│   │   └── AppEnvironment.swift
│   │
│   ├── Domain/
│   │   ├── Models/
│   │   │   ├── MediaAsset.swift
│   │   │   ├── MediaSource.swift
│   │   │   ├── AvailabilityState.swift
│   │   │   └── VerificationState.swift
│   │   └── Services/
│   │       └── MediaRepository.swift
│   │
│   ├── Sources/
│   │   ├── Photos/
│   │   │   └── PhotosLibraryAdapter.swift
│   │   ├── Filesystem/
│   │   │   └── FilesystemAdapter.swift
│   │   └── iOS/
│   │       └── IOSDeviceAdapter.swift
│   │
│   ├── Scanning/
│   │   ├── MediaScanner.swift
│   │   └── AvailabilityResolver.swift
│   │
│   ├── Hashing/
│   │   ├── SHA256Hasher.swift
│   │   └── PerceptualHasher.swift
│   │
│   ├── Duplicates/
│   │   ├── DuplicateDetector.swift
│   │   └── DuplicateIndex.swift
│   │
│   ├── Backup/
│   │   ├── BackupEngine.swift
│   │   ├── BackupJob.swift
│   │   ├── CopyOperation.swift
│   │   └── VerificationService.swift
│   │
│   ├── Jobs/
│   │   ├── JobCoordinator.swift
│   │   ├── ProgressReporter.swift
│   │   └── RetryPolicy.swift
│   │
│   ├── UI/
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   └── Components/
│   │
│   └── CLI/
│       └── CLICommands.swift
│
├── Tests/
│   ├── DomainTests/
│   ├── ScannerTests/
│   ├── HashingTests/
│   ├── DuplicateTests/
│   ├── BackupTests/
│   └── Fixtures/
│
├── Scripts/
│   └── development/
│
├── Documentation/
│   ├── Architecture.md
│   ├── Permissions.md
│   ├── Privacy.md
│   └── Recovery.md
│
├── .gitignore
├── LICENSE
└── README.md
```

> **Note:** The structure above is the intended architecture, not a
> claim that every directory or source file already exists. The
> repository should be inspected before implementing against a path or
> component.

------------------------------------------------------------------------

## 🔐 Safety Invariants

These rules apply to every implementation and automation agent:

1.  **Never delete originals by default.**
2.  **Never mutate iCloud or iOS sources while scanning or backing up.**
3.  **Never report a file as backed up before destination verification
    succeeds.**
4.  **Never treat a partial download as a valid original.**
5.  **Never overwrite existing files without explicit user approval.**
6.  **Never follow symlinks outside the selected source and destination
    boundaries without an explicit design decision.**
7.  **Keep operations cancellable and preserve completed work.**
8.  **Surface permission, mount, network, checksum, and disk-space
    errors.**
9.  **Do not silently downgrade failures to success.**
10. **Avoid logging private media contents.**
11. **Redact secrets, account information, and sensitive identifiers
    from logs.**

------------------------------------------------------------------------

## 🔎 Duplicate Detection

Duplicate detection should use progressively more expensive checks:

``` text
File metadata
     │
     ▼
Candidate grouping
     │
     ▼
SHA-256
     │
     ├── Exact match ──► Duplicate
     │
     └── Different ────► Not an exact duplicate
                           │
                           ▼
                    Optional pHash
                           │
                           ▼
                  Visually similar
```

### Exact duplicates

SHA-256 should be used to establish byte-for-byte equality.

### Visual similarity

Perceptual hashing may be used to find:

-   Resized images
-   Re-encoded images
-   Visually similar photographs
-   Potentially similar video frames

Visual similarity must never automatically trigger deletion or
overwriting.

------------------------------------------------------------------------

## 💾 Backup Pipeline

A backup job should follow this sequence:

``` text
Select source
     │
     ▼
Validate source
     │
     ▼
Select destination
     │
     ▼
Validate mounted + writable volume
     │
     ▼
Discover eligible assets
     │
     ▼
Check duplicates / existing files
     │
     ▼
Copy to temporary destination
     │
     ▼
Finalize atomically
     │
     ▼
Verify size + SHA-256
     │
     ▼
Mark backup as verified
```

A backup is considered **complete only after verification succeeds**.

The backup engine should also support:

-   Resume after interruption
-   Cancellation
-   Retry of failed files
-   Separate success/failure reporting
-   Explicit overwrite policies
-   APFS and exFAT destinations

------------------------------------------------------------------------

## 🛡️ Privacy & Permissions

The application should request only the permissions required for the
operation, potentially including:

-   Photos library access
-   Removable-volume access
-   Access to connected devices

Every permission should be explained clearly in the application and
development documentation.

The application should avoid collecting or transmitting media
unnecessarily. Logs should contain only the information required for
troubleshooting and operation.

Do not commit:

-   Photos libraries
-   Personal media
-   Device backups
-   Credentials
-   API keys
-   Account information
-   Generated Xcode user data
-   Build products

------------------------------------------------------------------------

## 💻 Requirements

-   **macOS 13 Ventura or later**
-   **Xcode** with the macOS SDK required by the project target
-   **Swift / Apple development toolchain** provided by Xcode
-   **Python 3.10+ and Homebrew** only if planned
    auxiliary/media-processing components are introduced
-   External storage formatted as **APFS** or **exFAT**
-   Sufficient free space for the selected backup

------------------------------------------------------------------------

## 🧪 Development & Testing

The repository currently contains an Xcode project container but does
not yet contain the complete application implementation or test suite.

Before implementing new functionality:

1.  Inspect the repository tree.
2.  Inspect Xcode targets and schemes.
3.  Check existing tests.
4.  Confirm whether the requested feature already exists.
5.  Prefer small, independently testable services.
6.  Preserve existing user changes.
7.  Update this README when architecture, dependencies, commands, or
    safety rules change.

### Recommended test coverage

Safety-critical behavior should be tested independently of real user
data:

-   SHA-256 hashing
-   Duplicate classification
-   Path handling
-   Symlink boundaries
-   Resume behavior
-   Atomic file finalization
-   Checksum verification
-   Insufficient disk space
-   Permission failures
-   Cancellation and retry behavior

Use temporary directories and generated fixtures for deterministic
tests.

Integration tests requiring Photos, iCloud, iOS devices, or external
drives should remain separate from unit tests.

### Local validation

Inspect available schemes before building:

``` bash
open apple-memory-management.xcodeproj

xcodebuild -list \
  -project apple-memory-management.xcodeproj

# Build/test using an explicitly discovered scheme and destination.
xcodebuild test \
  -project apple-memory-management.xcodeproj \
  -scheme <SCHEME> \
  -destination '<DESTINATION>'
```

------------------------------------------------------------------------

## 🗺️ Roadmap

-   [ ] Define the macOS application target.
-   [ ] Define the supported CLI interface.
-   [ ] Add the media asset model.
-   [ ] Implement source-adapter abstractions.
-   [ ] Implement read-only Photos library discovery.
-   [ ] Add local/iCloud availability reporting.
-   [ ] Implement SHA-256 exact duplicate detection.
-   [ ] Add optional pHash-based similarity analysis.
-   [ ] Implement resumable backups.
-   [ ] Add APFS and exFAT destination support.
-   [ ] Add destination verification.
-   [ ] Add progress reporting and cancellation.
-   [ ] Add structured logging and error summaries.
-   [ ] Add deterministic unit tests and fixtures.
-   [ ] Document permissions and privacy.
-   [ ] Document recovery and backup procedures.
-   [ ] Prepare release and distribution procedures.

------------------------------------------------------------------------

## 🤝 Contributing

Contributions are welcome.

When contributing:

1.  Keep changes focused and testable.
2.  Do not introduce destructive behavior without explicit confirmation.
3.  Add or update tests for safety-critical behavior.
4.  Preserve privacy and avoid committing real user media.
5.  Update documentation when behavior or architecture changes.

------------------------------------------------------------------------

## 📄 License

This project is licensed under the **MIT License**.

A copy of the license is available in the [`LICENSE`](LICENSE) file.

Copyright (c) 2026 Gustavo Lopes Nomelini

------------------------------------------------------------------------

## ⚠️ Project Status

This project is under active development.

The current repository is an initial scaffold, so documentation may
describe planned architecture and behavior that has not yet been
implemented.

**Do not assume that a documented feature is already available until it
exists in the repository and has been validated.**

