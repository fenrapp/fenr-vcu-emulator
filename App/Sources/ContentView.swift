import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: Layout.spacing) {
            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.largeTitle)
            Text("FENR VCU Emulator").font(.title)
            Text("Local Bluetooth development environment")
                .foregroundStyle(.secondary)
        }
        .padding(Layout.padding)
        .frame(minWidth: Layout.width, minHeight: Layout.height)
    }

    private enum Layout {
        static let spacing: CGFloat = 16
        static let padding: CGFloat = 32
        static let width: CGFloat = 640
        static let height: CGFloat = 480
    }
}
