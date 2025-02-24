import PDFKit
import SwiftUI
import VisionKit

public struct DocumentScannerView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    
    public var onCompletion: (Result<PDFDocument, Error>) -> Void
    
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
    
    public class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var parent: DocumentScannerView
        
        init(_ parent: DocumentScannerView) {
            self.parent = parent
        }
        
        public func documentCameraViewController(_: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
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
        
        public func documentCameraViewControllerDidCancel(_: VNDocumentCameraViewController) {
            parent.dismiss()
        }
        
        public func documentCameraViewController(_: VNDocumentCameraViewController, didFailWithError error: Error) {
            print("Error:", error)
            parent.onCompletion(.failure(error))
            parent.dismiss()
        }
    }
}
