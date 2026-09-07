# Apple Media Manager & Backup Tool

Apple Media Manager is a macOS utility for organizing, verifying, and backing up
photo and video libraries from macOS Photos and connected iOS devices. Its
primary goal is to make local storage and backup state observable without
deleting or modifying media unless the user explicitly approves the operation.

The planned workflow is:

1. Discover media in the macOS Photos library and connected iOS devices.
2. Determine whether each asset is available locally, fully stored in iCloud,
   or still being synchronized.
3. Identify exact duplicates and visually similar files.
4. Back up eligible, full-resolution assets to a user-selected external volume.
5. Report progress, verification results, duplicates, failures, and storage
   savings in both the app and terminal-friendly output.

> **Project status:** This repository is currently an initial Xcode project
> scaffold. The media scanning, iCloud verification, duplicate detection, and
> backup pipeline described below still need to be implemented. Agents must
> inspect the repository before assuming that a component or command exists.

## Goals and non-goals

### Goals

- Provide reliable, repeatable backups of local Apple media.
- Distinguish cloud-only, locally available, downloading, and verified assets.
- Detect duplicates before copying and never silently discard user data.
- Support external drives formatted as APFS or exFAT.
- Expose progress and actionable errors during long-running operations.
- Make all destructive or potentially irreversible actions explicit and
  user-confirmed.

### Non-goals

- Replacing iCloud Photos or acting as an iCloud synchronization service.
- Treating a filename, path, or file size as proof that two assets are identical.
- Deleting originals, Photos library records, or iCloud assets automatically.
- Assuming that a connected iOS device is writable or continuously available.

## Core behavior

### Media discovery and iCloud verification

The scanner should use supported Apple APIs and filesystem metadata where
available. Each asset should have a stable internal identity and a verification
state, such as:

- `local`: the complete original is available on the Mac.
- `cloud-only`: the original is not currently stored locally.
- `downloading`: the asset is being fetched from iCloud.
- `verified`: the local copy has passed integrity checks.
- `unavailable`: the source could not be reached or the asset could not be
  inspected.

Verification must not equate a Photos thumbnail or preview with a
full-resolution original. Network failures, permission failures, and
incomplete downloads must remain visible to the user.

### Duplicate detection

Use multiple signals with increasing cost:

1. File metadata for inexpensive candidate grouping.
2. SHA-256 for exact byte-for-byte duplicates.
3. Perceptual hashing (pHash) for visually similar images or videos when
   supported.

Perceptual similarity is advisory, not proof of equivalence. The tool must
never delete or overwrite a file solely because pHash values are close.
Duplicate results should identify the files, algorithm, confidence, and reason
for the match so the user or a future agent can review the decision.

### Backup pipeline

The backup pipeline should:

- Require an explicit source and destination.
- Confirm that the destination volume is mounted and writable.
- Preserve original media bytes and meaningful metadata where possible.
- Avoid overwriting existing files unless the user explicitly selects that
  behavior.
- Write to a temporary path and atomically finalize each completed copy.
- Verify the destination after copying using size and SHA-256.
- Support resuming after interruption without corrupting completed files.
- Record failures separately from successful copies.

No backup is considered complete until its verification phase succeeds.

## Safety invariants

These rules apply to every implementation and automation agent:

- Never delete originals or Photos library content by default.
- Never mutate an iCloud or iOS source while scanning or backing up.
- Never report a file as backed up before destination verification succeeds.
- Never treat a partial download as a valid original.
- Never follow symlinks or copy outside the selected source and destination
  boundaries without an explicit design decision.
- Keep operations cancellable and leave already completed work intact.
- Surface permission, mount, network, checksum, and disk-space errors; do not
  silently downgrade them to success.
- Avoid logging private media contents. Logs should contain identifiers and
  paths only when necessary and should redact secrets or account data.

## Repository guidance for agents

Before making changes:

1. Inspect the repository tree, Xcode project settings, targets, schemes, and
   existing tests.
2. Confirm whether the requested behavior is part of the current scaffold or
   requires introducing a new component.
3. Prefer small, testable services with explicit inputs and outputs over a
   single scan-and-copy routine.
4. Preserve user data and existing user changes; do not reset unrelated files.
5. Update this README when a command, dependency, architecture decision, or
   safety invariant changes.

When implementing a feature, document:

- The source of truth for media identity.
- Permission requirements and failure states.
- Whether the operation is read-only, reversible, or destructive.
- How cancellation and retries behave.
- How the behavior is tested without relying on a real Photos library, iCloud
  account, iOS device, or external drive.

### Suggested component boundaries

The implementation can be organized around these responsibilities:

- **Source adapters:** Photos library, filesystem, and connected iOS devices.
- **Asset model:** stable identity, location, availability, metadata, and
  verification state.
- **Scanner:** discovery and incremental change detection.
- **Hasher:** SHA-256 and optional perceptual hashing.
- **Duplicate index:** candidate grouping and explainable match results.
- **Backup engine:** copy, resume, atomic finalize, and destination verification.
- **Job coordinator:** cancellation, retries, progress, and structured errors.
- **Presentation/CLI layer:** human-readable output and machine-readable
  progress events.

These are design boundaries, not an assertion that all components already
exist in the repository.

## Requirements

- macOS 13 Ventura or later.
- Xcode and the macOS SDK required by the project target.
- Python 3.10+ and Homebrew for planned command-line/media-processing support,
  if those components are introduced.
- An external volume formatted as APFS or exFAT for large backups.
- Sufficient free space for the selected backup and verification workflow.

The tool should request only the permissions it needs, such as Photos library
access, removable-volume access, and access to connected devices. Implementers
should explain any required permission in the UI and development
documentation.

## Development and validation

The repository currently contains the Xcode project container but no checked-in
application source or test suite. Until targets and schemes are added:

- Do not invent a production command or claim that the backup workflow runs.
- Inspect available schemes before invoking `xcodebuild`.
- Add unit tests for hashing, duplicate classification, path handling, resume
  behavior, and checksum verification before integrating real Apple services.
- Use temporary directories and generated fixtures for backup tests.
- Keep integration tests that require Photos, iCloud, iOS devices, or external
  volumes separate from deterministic unit tests.

Once an executable target exists, a typical local validation flow is:

```bash
open apple-memory-management.xcodeproj
xcodebuild -list -project apple-memory-management.xcodeproj
# Build and test using an explicitly discovered scheme and destination.
```

Do not commit generated Xcode user data, build products, credentials, Photos
library contents, device backups, or real user media.

## Roadmap

- [ ] Define the macOS app target and supported command-line interface.
- [ ] Add a media asset model and source-adapter abstraction.
- [ ] Implement read-only Photos/library discovery.
- [ ] Add local availability and iCloud synchronization-state reporting.
- [ ] Implement SHA-256 exact duplicate detection.
- [ ] Add optional pHash-based similarity analysis with reviewable results.
- [ ] Implement resumable, verified backups to APFS and exFAT volumes.
- [ ] Add progress reporting, cancellation, structured logs, and summaries.
- [ ] Add deterministic tests and fixtures for all safety-critical behavior.
- [ ] Document permissions, privacy, recovery, and release procedures.

## License

No license has been declared yet. Do not assume that this project may be
redistributed until a license is added.
