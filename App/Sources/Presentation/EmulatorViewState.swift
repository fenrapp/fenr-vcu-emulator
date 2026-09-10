import Foundation

struct EmulatorViewState {
    var transport = String(localized: "Stopped")
    var authentication = String(localized: "No authenticated session")
    var running = false
    var activity: [ActivityRow] = []
}

struct ActivityRow: Identifiable {
    let id = UUID()
    let time: String
    let detail: String
}
