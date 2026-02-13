import PDFKit
import SwiftData
import SwiftUI

/// A SwiftUI view that displays a list of documents and allows users to scan new documents.
///
/// The `DocumentList` view presents a list of scanned documents and provides a toolbar button
/// to initiate a document scanning process. Users can rename or delete documents from the list,
/// and they can navigate to a detailed view of each document.
struct DocumentList: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Document.dateCreated, order: .reverse) private var scans: [Document]
    
    @AppStorage("Doc Number") private var docNumber = 1
    @State private var isShowingScanner = false
    @State private var showAlert = false
    @State private var selected: Document?
    @Namespace private var namespace
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                    ForEach(scans, id: \.self) { document in
                        DocumentLink(document: document, namespace: namespace) { document in
                            selected = document
                        }
                    }
                }
                .padding()
                .fullScreenCover(item: $selected) { document in
                    NavigationStack {
                        DocumentPreview(document: document)
                    }
                    .navigationTransition(.zoom(sourceID: document.id, in: namespace))
                }
            }
            .toolbar {
                showScannerButton
            }
            .fullScreenCover(isPresented: $isShowingScanner) {
                scannerSheet
            }
            .alert("Failed to scan document", isPresented: $showAlert) {}
            .navigationTitle("Documents")
        }
    }
    
    private var showScannerButton: some View {
        Button {
            isShowingScanner = true
        } label: {
            Image(systemName: "document.viewfinder")
        }
    }
    
    private var scannerSheet: some View {
        DocumentScanner { result in
            switch result {
            case let .success(document):
                if let document = Document(name: "Document \(self.docNumber)",
                                           dateCreated: Date.now,
                                           document: document) {
                    modelContext.insert(document)
                    docNumber += 1
                } else {
                    showAlert = true
                }
                              
            case .failure:
                showAlert = true
            }
        }
    }
}

#Preview {
    DocumentList()
        .modelContainer(.previewContainer)
}
