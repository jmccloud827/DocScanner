import SwiftUI
import SwiftData

@main
struct DocScannerApp: App {
    var body: some Scene {
        WindowGroup {
            DocumentList()
        }
        .modelContainer(for: Document.self)
    }
}

/// App Icon
#Preview {
    Image(systemName: "document.viewfinder")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .foregroundStyle(.white)
            .frame(width: 300, height: 300)
        .padding()
        .padding()
        .padding()
        .padding()
        .background(Color("Color").gradient)
}
