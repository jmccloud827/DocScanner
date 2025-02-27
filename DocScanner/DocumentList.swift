import SwiftData
import SwiftUI

/// A SwiftUI view that displays a list of documents and allows users to scan new documents.
///
/// The `DocumentList` view presents a list of scanned documents and provides a toolbar button
/// to initiate a document scanning process. Users can rename or delete documents from the list,
/// and they can navigate to a detailed view of each document.
struct DocumentList: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query private var scans: [Document]
    
    @AppStorage("Doc Number") private var docNumber = 1
    @State private var isShowingScanner = false
    @State private var showAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(scans, id: \.self) { document in
                    DocumentLink(document: document)
                }
            }
            .navigationDestination(for: Document.self) { document in
                DocumentView(document: document)
            }
            .toolbar {
                Button {
                    isShowingScanner = true
                } label: {
                    Image(systemName: "document.viewfinder")
                }
            }
            .fullScreenCover(isPresented: $isShowingScanner) {
                DocumentScannerView { result in
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
            .alert("Failed to scan document", isPresented: $showAlert) {}
            .navigationTitle("Documents")
        }
    }
    
    /// A nested view that represents a link to a specific document.
    ///
    /// The `DocumentLink` view allows users to edit the document's name
    /// and provides context menu options for renaming or deleting the document.
    struct DocumentLink: View {
        @Environment(\.modelContext) private var modelContext
        
        let document: Document
        
        @State private var text = ""
        @FocusState private var focus: Bool
        
        var body: some View {
            NavigationLink(value: document) {
                HStack {
                    TextField("", text: $text)
                        .focused($focus)
                    
                    Spacer()
                    
                    Text(document.dateCreated.formatted(date: .abbreviated, time: .shortened))
                }
            }
            .submitLabel(.done)
            .contextMenu {
                renameButton
                
                deleteButton
            }
            .swipeActions {
                deleteButton
                
                renameButton
                    .tint(.green)
            }
            .onChange(of: focus) {
                if !focus && !text.isEmpty {
                    document.name = text
                } else {
                    text = document.name
                }
            }
            .onAppear {
                text = document.name
            }
        }
        
        /// A button for renaming the document.
        private var renameButton: some View {
            Button {
                focus = true
            } label: {
                Label("Rename", systemImage: "pencil")
            }
        }
        
        /// A button for deleting the document.
        private var deleteButton: some View {
            Button(role: .destructive) {
                modelContext.delete(document)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    DocumentList()
}
