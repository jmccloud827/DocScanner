import PDFKit
import SwiftUI

/// A SwiftUI view for displaying PDF documents using PDFKit.
///
/// The `PDFView` struct provides an interface for rendering PDF documents within a SwiftUI view.
public struct PDFView: View {
    private let pdfView: PDFKit.PDFView
    
    /// Initializes a new instance of `PDFView` with a given `PDFDocument`.
    ///
    /// - Parameter pdfDoc: The PDF document to be displayed.
    public init(showing pdfDoc: PDFDocument) {
        self.pdfView = PDFKit.PDFView()
        
        pdfView.document = pdfDoc
    }
    
    /// Initializes a new instance of `PDFView` with a PDF file from the main bundle.
    ///
    /// - Parameter name: The name of the PDF file (without extension) to be loaded from the main bundle.
    public init(named name: String) {
        self.pdfView = PDFKit.PDFView()
        
        pdfView.document = PDFDocument(url: Bundle.main.url(forResource: name, withExtension: "pdf")!)!
    }
    
    public var body: some View {
        PDFUIView(pdfView)
    }
    
    private struct PDFUIView: UIViewRepresentable {
        let pdfView: PDFKit.PDFView
        
        init(_ pdfView: PDFKit.PDFView) {
            self.pdfView = pdfView
        }
        
        func makeUIView(context _: Context) -> PDFKit.PDFView {
            pdfView.autoScales = true
            return pdfView
        }
        
        func updateUIView(_: PDFKit.PDFView, context _: Context) {}
    }
}

public extension PDFDocument {
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
