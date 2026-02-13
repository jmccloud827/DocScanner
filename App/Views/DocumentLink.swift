import SwiftUI

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
                documentImage
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
                        contextMenuButtons
                    }
                    .frame(maxWidth: 100, maxHeight: 150, alignment: .bottom)
            }
            .frame(width: 100, height: 150)
            
            documentDetails
            
            Spacer()
        }
        .submitLabel(.done)
        .onChange(of: focus, onChangeOfFocus)
        .onAppear(perform: onAppear)
    }
    
    @ViewBuilder private var documentImage: some View {
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
    
    @ViewBuilder private var contextMenuButtons: some View {
        if let imageRepresentation = document.pdfDocument?.imageRepresentation {
            ShareLink(item: document.transferableRepresentation,
                      preview: SharePreview(document.name,
                                            image: Image(uiImage: imageRepresentation)))
        } else {
            ShareLink(item: document.transferableRepresentation,
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
    
    @ViewBuilder private var documentDetails: some View {
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
    }
    
    private func onChangeOfFocus() {
        if !focus {
            if !text.isEmpty {
                document.name = text
            }
            
            isEditing = false
        } else {
            text = document.name
        }
    }
    
    private func onAppear() {
        text = document.name
    }
}
