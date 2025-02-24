import SwiftData
import SwiftUI

struct DocumentView: View {
    @Environment(\.modelContext) private var modelContext
    let document: Document
    
    var body: some View {
        Group {
            if let pdfDocument = document.pdfDocument {
                PDFView(showing: pdfDocument)
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
