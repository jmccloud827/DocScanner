import PDFKit
import SwiftData
import SwiftUI

/// A model class representing a document with associated metadata.
///
/// The `Document` class conforms to `Hashable` and `Identifiable` protocols,
/// allowing it to be used within collections, uniquely identified, and transferred between applications.
@Model class Document: Hashable, Identifiable {
    /// A unique identifier for the document.
    var id = UUID()
    
    /// The name of the document.
    var name: String = ""
    
    /// The date when the document was created.
    var dateCreated: Date = Date.now
    
    /// The raw data of the document.
    var document: Data = Data()
    
    /// Initializes a new instance of `Document` with the provided name, creation date, and document data.
    ///
    /// - Parameters:
    ///   - name: The name of the document.
    ///   - dateCreated: The date when the document was created.
    ///   - data: The raw data representing the document.
    init(name: String, dateCreated: Date, data: Data) {
        self.name = name
        self.dateCreated = dateCreated
        self.document = data
    }
    
    /// Initializes a new instance of `Document` from a `PDFDocument`.
    ///
    /// - Parameters:
    ///   - name: The name of the document.
    ///   - dateCreated: The date when the document was created.
    ///   - document: The `PDFDocument` to be converted into a `Document`.
    /// - Returns: A new instance of `Document`, or `nil` if the PDF document could not be converted into data.
    init?(name: String, dateCreated: Date, document: PDFDocument) {
        if let documentData = document.dataRepresentation() {
            self.name = name
            self.dateCreated = dateCreated
            self.document = documentData
        } else {
            return nil
        }
    }
    
    /// A computed property that returns a `PDFDocument` representation of the document data.
    var pdfDocument: PDFDocument? {
        return PDFDocument(data: document)
    }
    
    /// A computed property that returns a `TransferableDocument` representation of the document data.
    var transferableRepresentation: TransferableDocument {
        .init(name: name, document: document)
    }
    
    /// A model class representing a transferable document with associated metadata.
    nonisolated struct TransferableDocument: Transferable {
        /// The name of the document.
        let name: String
        /// The raw data of the document.
        let document: Data
        
        /// A static property defining the transfer representation for the `Document` class.
        ///
        /// This representation allows documents to be imported and exported as PDF files.
        public static var transferRepresentation: some TransferRepresentation {
            DataRepresentation(exportedContentType: .pdf) { document in
                document.document
            }
            .suggestedFileName { document in
                document.name
            }
        }
    }
}

/// An extension to `PDFDocument` providing a method to generate an image representation of the first page.
///
/// This extension adds functionality to create a `UIImage` representation of the first page of a PDF document.
public extension PDFDocument {
    /// A computed property that returns an image representation of the first page of the PDF document.
    var imageRepresentation: UIImage? {
        guard let pdfPage = self.page(at: 0) else {
            return nil
        }
        let pageBounds = pdfPage.bounds(for: .cropBox)

        let renderer = UIGraphicsImageRenderer(size: pageBounds.size)
        return renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageBounds)

            ctx.cgContext.translateBy(x: 0.0, y: pageBounds.size.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

            UIGraphicsPushContext(ctx.cgContext)
            pdfPage.draw(with: .cropBox, to: ctx.cgContext)
            UIGraphicsPopContext()
        }
    }
}
