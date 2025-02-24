import SwiftUI
import PDFKit
import SwiftData

@Model class Document: Hashable, Identifiable, Transferable {
    var id = UUID()
    var name: String
    var dateCreated: Date
    var document: Data
    
    init(name: String, dateCreated: Date, data: Data) {
        self.name = name
        self.dateCreated = dateCreated
        self.document = data
    }
    
    init?(name: String, dateCreated: Date, document: PDFDocument) {
        if let documentData = document.dataRepresentation() {
            self.name = name
            self.dateCreated = dateCreated
            self.document = documentData
        } else {
            return nil
        }
    }
    
    var pdfDocument: PDFDocument? {
        return PDFDocument(data: document)
    }
    
    public static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(contentType: .pdf) { document in
            document.document
        } importing: { data in
            Document(name: "Imported Document \(UUID().uuidString)", dateCreated: Date.now, data: data)
        }
        .suggestedFileName { document in
            document.name
        }
        DataRepresentation(exportedContentType: .pdf) { document in
            document.document
        }
        .suggestedFileName { document in
            document.name
        }
    }
}
