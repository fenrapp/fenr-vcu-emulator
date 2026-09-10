import Foundation

struct EmulatorViewState {
    var transport = String(localized: "Stopped")
    var authentication = String(localized: "No authenticated session")
    var running = false
    var activity: [ActivityRow] = []
}
