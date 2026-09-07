@MainActor
final class AppEnvironment {
    let scanner: MediaScanner
    let backupEngine: BackupEngine

    init(
        scanner: MediaScanner = MediaScanner(),
        backupEngine: BackupEngine = BackupEngine()
    ) {
        self.scanner = scanner
        self.backupEngine = backupEngine
    }
}
