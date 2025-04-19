import Foundation
import SwiftUI

class ReceiptGalleryViewModel: ObservableObject {
    @Published var receipts: [Receipt] = []
    private let repository: ReceiptRepository
    
    init(repository: ReceiptRepository) {
        self.repository = repository
        loadReceipts()
    }
    
    func loadReceipts() {
        _ = repository.getAllReceipts()
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] receipts in
                self?.receipts = receipts
            })
    }
    
    func loadThumbnail(for receipt: Receipt) -> UIImage? {
        // 根據 filePath 載入縮圖
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: receipt.filePath)),
              let image = UIImage(data: data) else { return nil }
        let size = CGSize(width: 60, height: 60)
        return image.resize(to: size)
    }
    
    func loadImage(for receipt: Receipt) -> UIImage? {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: receipt.filePath)) else { return nil }
        return UIImage(data: data)
    }
    
    func deleteReceipts(at offsets: IndexSet) {
        for index in offsets {
            let receipt = receipts[index]
            _ = repository.deleteReceipt(id: receipt.uuid)
                .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] in
                    self?.receipts.remove(at: index)
                })
        }
    }
}

// MARK: - UIImage Resize Helper
extension UIImage {
    func resize(to targetSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
