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
                .sheet(item: $selected) { document in
                    NavigationStack {
                        DocumentView(document: document)
                    }
                    .navigationTransition(.zoom(sourceID: document.id, in: namespace))
                }
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
        let namespace: Namespace.ID
        let onSelectDocument: (Document) -> Void
        
        @State private var text = ""
        @State private var isEditing = false
        @FocusState private var focus: Bool
        
        var body: some View {
            VStack {
                Button {
                    onSelectDocument(document)
                } label: {
                    Group {
                        if let uiImage = document.pdfDocument?.imageRepresentation {
                            Image(uiImage: uiImage)
                                .resizable()
                                .interpolation(.high)
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerSize: .init(width: 5, height: 5), style: .continuous))
                        } else {
                            Image(systemName: "document")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding()
                                .padding()
                                .foregroundStyle(.gray)
                                .frame(width: 100, height: 150)
                        }
                    }
                    .matchedTransitionSource(id: document.id, in: namespace)
                    .background {
                        RoundedRectangle(cornerSize: .init(width: 5, height: 5), style: .continuous)
                            .fill(Color(.secondarySystemGroupedBackground))
                    }
                    .overlay {
                        RoundedRectangle(cornerSize: .init(width: 5, height: 5), style: .continuous)
                            .stroke(lineWidth: 0.5)
                            .fill(.black.opacity(0.5))
                    }
                    .contextMenu {
                        if let imageRepresentation = document.pdfDocument?.imageRepresentation {
                            ShareLink(item: document,
                                      preview: SharePreview(document.name,
                                                            image: Image(uiImage: imageRepresentation)))
                        } else {
                            ShareLink(item: document,
                                      preview: SharePreview(document.name))
                        }
                        
                        Button {
                            isEditing = true
                            focus = true
                        } label: {
                            Label("Rename", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive) {
                            modelContext.delete(document)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .frame(maxWidth: 100, maxHeight: 150, alignment: .bottom)
                }
                .frame(width: 100, height: 150)
                
                if isEditing {
                    TextField(document.name, text: $text)
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.center)
                        .focused($focus)
                } else {
                    Text(document.name)
                        .multilineTextAlignment(.center)
                        .onTapGesture {
                            isEditing = true
                            focus = true
                        }
                }
                
                Text(document.dateCreated.formatted(date: .numeric, time: .omitted))
                    .foregroundStyle(.gray)
                    .font(.caption)
                
                Text(document.document.count.formatted(.byteCount(style: .memory)).uppercased())
                    .foregroundStyle(.gray)
                    .font(.caption)
                
                Spacer()
            }
            .submitLabel(.done)
            .onChange(of: focus) {
                if !focus {
                    if !text.isEmpty {
                        document.name = text
                    }
                    
                    isEditing = false
                } else {
                    text = document.name
                }
            }
            .onAppear {
                text = document.name
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Document.self, configurations: config)
    
    let pdf = PDFDocument(url: Bundle.main.url(forResource: "sample", withExtension: "pdf")!)!
    
    container.mainContext.insert(Document(name: "Test", dateCreated: Date.now, document: pdf)!)
    container.mainContext.insert(Document(name: "Test 2", dateCreated: Date.distantFuture, document: pdf)!)
    container.mainContext.insert(Document(name: "Test 3", dateCreated: Date.distantPast, document: pdf)!)
    container.mainContext.insert(Document(name: "Test 4", dateCreated: Date.now, data: Data()))
    
    return DocumentList()
        .modelContainer(container)
}
