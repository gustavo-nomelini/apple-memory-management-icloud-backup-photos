import SwiftUI

@main
struct AppleMediaManagerApp: App {
    @State private var environment = AppEnvironment()

    var body: some Scene {
        WindowGroup {
            ContentView(environment: environment)
        }
    }
}
