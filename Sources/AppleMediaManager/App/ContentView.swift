import SwiftUI

struct ContentView: View {
    let environment: AppEnvironment

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("Apple Media Manager")
                .font(.title)

            Text("Scan a source to inspect media availability and prepare a verified backup.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button("Start scan") {
                environment.scanner.reset()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(32)
        .frame(minWidth: 420, minHeight: 260)
    }
}
