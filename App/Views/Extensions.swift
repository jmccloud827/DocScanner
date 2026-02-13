import PDFKit
import SwiftData
import SwiftUI

extension ModelContainer {
    static var previewContainer: ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Document.self, configurations: config)
            
        let pdf = PDFDocument(url: Bundle.main.url(forResource: "sample", withExtension: "pdf")!)!
            
        container.mainContext.insert(Document(name: "Test", dateCreated: Date.now, document: pdf)!)
        container.mainContext.insert(Document(name: "Test 2", dateCreated: Date.distantFuture, document: pdf)!)
        container.mainContext.insert(Document(name: "Test 3", dateCreated: Date.distantPast, document: pdf)!)
        container.mainContext.insert(Document(name: "Test 4", dateCreated: Date.now, data: Data()))
        
        return container
    }
}
