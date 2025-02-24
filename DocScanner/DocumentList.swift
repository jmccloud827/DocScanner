import SwiftData
import SwiftUI

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
        
        private var renameButton: some View {
            Button {
                focus = true
            } label: {
                Label("Rename", systemImage: "pencil")
            }
        }
        
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
