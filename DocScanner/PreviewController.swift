import PDFKit
import QuickLook
import SwiftUI

/// A SwiftUI view that presents a PDF document using a `QLPreviewController`.
struct PreviewController: UIViewControllerRepresentable {
    /// The PDF document to be previewed.
    let pdfDocument: PDFDocument
    
    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }
    
    func updateUIViewController(_: QLPreviewController, context _: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: QLPreviewControllerDataSource {
        let parent: PreviewController
        
        /// Initializes a new `Coordinator`.
                ///
                /// - Parameter parent: The parent `PreviewController` instance.
        init(parent: PreviewController) {
            self.parent = parent
        }
        
        /// Returns the number of preview items.
         ///
         /// - Parameter controller: The `QLPreviewController` requesting the number of items.
         /// - Returns: The number of preview items, which is 1 for this implementation.
        func numberOfPreviewItems(in _: QLPreviewController) -> Int {
            return 1
        }
        
        /// Provides the preview item at the specified index.
                ///
                /// - Parameters:
                ///   - controller: The `QLPreviewController` requesting the preview item.
                ///   - index: The index of the requested preview item.
                /// - Returns: A `QLPreviewItem` representing the PDF document.
        func previewController(_: QLPreviewController,
                               previewItemAt _: Int) -> QLPreviewItem {
            let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("temp.pdf")
                        
            do {
                try parent.pdfDocument.dataRepresentation()?.write(to: documentURL)
            } catch {
                print("error is \(error.localizedDescription)")
            }
            return documentURL as NSURL
        }
    }
}
