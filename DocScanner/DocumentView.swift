import SwiftData
import SwiftUI

/// A SwiftUI view that displays a PDF document.
///
/// The `DocumentView` struct shows a PDF document, allowing users to view its content
/// and share it with others. If the PDF document cannot be loaded, an error message is displayed.
struct DocumentView: View {
    @Environment(\.modelContext) private var modelContext
    let document: Document
    
    var body: some View {
        Group {
            if let pdfDocument = document.pdfDocument {
                PreviewController(pdfDocument: pdfDocument)
                    .toolbar {
                        if let imageRepresentation = pdfDocument.imageRepresentation {
                            ShareLink(item: document,
                                      preview: SharePreview(document.name,
                                                            image: Image(uiImage: imageRepresentation)))
                        } else {
                            ShareLink(item: document,
                                      preview: SharePreview(document.name))
                        }
                    }
                    .ignoresSafeArea()
            } else {
                Text("Failed to load PDF")
            }
        }
        .navigationTitle(document.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
