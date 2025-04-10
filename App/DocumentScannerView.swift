import PDFKit
import SwiftUI
import VisionKit

/// A SwiftUI view that provides a document scanning interface using `VNDocumentCameraViewController`.
///
/// The `DocumentScannerView` allows users to scan documents and convert them into a `PDFDocument`.
/// Upon completion of the scanning process, it returns the scanned PDF document via a completion handler.
public struct DocumentScannerView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    
    /// A closure that is called upon the completion of the document scanning process.
    ///
    /// - Parameter result: A `Result` containing either the scanned `PDFDocument` or an `Error` if the scan fails.
    public var onCompletion: (Result<PDFDocument, Error>) -> Void
    
    /// Initializes a new instance of `DocumentScannerView`.
    ///
    /// - Parameter onCompletion: A closure that is called with the result of the document scanning operation.
    public init(onCompletion: @escaping (Result<PDFDocument, Error>) -> Void) {
        self.onCompletion = onCompletion
    }
    
    public func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let vc = VNDocumentCameraViewController()
        vc.delegate = context.coordinator
        return vc
    }
    
    public func updateUIViewController(_: VNDocumentCameraViewController, context _: Context) {}
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    /// A coordinator class that conforms to `VNDocumentCameraViewControllerDelegate`.
    ///
    /// The `Coordinator` manages the interactions between the `DocumentScannerView` and the
    /// `VNDocumentCameraViewController`, handling delegate callbacks for document scanning.
    public class Coordinator: NSObject, @preconcurrency VNDocumentCameraViewControllerDelegate {
        var parent: DocumentScannerView
        
        /// Initializes a new instance of `Coordinator` with the specified parent `DocumentScannerView`.
        ///
        /// - Parameter parent: The parent `DocumentScannerView` instance.
        init(_ parent: DocumentScannerView) {
            self.parent = parent
        }
        
        /// Called when the document scanning is finished successfully.
        ///
        /// - Parameters:
        ///   - controller: The `VNDocumentCameraViewController` that finished scanning.
        ///   - scan: The result of the scan containing the scanned document pages.
        @MainActor public func documentCameraViewController(_: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            let images = (0 ..< scan.pageCount).map(scan.imageOfPage(at:))
            let pdf = PDFDocument()
            for i in 0 ..< images.count {
                if let page = PDFPage(image: images[i]) {
                    pdf.insert(page, at: i)
                }
            }
            
            parent.onCompletion(.success(pdf))
            parent.dismiss()
        }
        
        /// Called when the document scanning is canceled by the user.
        ///
        /// - Parameter controller: The `VNDocumentCameraViewController` that was canceled.
        @MainActor public func documentCameraViewControllerDidCancel(_: VNDocumentCameraViewController) {
            parent.dismiss()
        }
        
        /// Called when the document scanning fails due to an error.
        ///
        /// - Parameters:
        ///   - controller: The `VNDocumentCameraViewController` that encountered an error.
        ///   - error: The error that occurred during scanning.
        @MainActor public func documentCameraViewController(_: VNDocumentCameraViewController, didFailWithError error: Error) {
            print("Error:", error)
            parent.onCompletion(.failure(error))
            parent.dismiss()
        }
    }
}
