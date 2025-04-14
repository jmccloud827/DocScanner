import SwiftData
import PDFKit
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
                    .ignoresSafeArea()
                    .toolbar {
                        shareButton(pdfDocument: pdfDocument)
                    }
            } else {
                Text("Failed to load PDF")
            }
        }
        .navigationTitle(document.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder private func shareButton(pdfDocument: PDFDocument) -> some View {
        if let imageRepresentation = pdfDocument.imageRepresentation {
            ShareLink(item: document,
                      preview: SharePreview(document.name,
                                            image: Image(uiImage: imageRepresentation)))
        } else {
            ShareLink(item: document,
                      preview: SharePreview(document.name))
        }
    }
}
