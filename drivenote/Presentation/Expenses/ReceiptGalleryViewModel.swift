import Foundation
import SwiftUI
import Combine

class ReceiptGalleryViewModel: ObservableObject {
    @Published var receipts: [Receipt] = []
    private let repository: ReceiptRepository
    private var cancellables = Set<AnyCancellable>()

    init(repository: ReceiptRepository) {
        self.repository = repository
        loadReceipts()
    }
    
    func loadReceipts() {
        repository.getAllReceipts()
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] receipts in
                self?.receipts = receipts
            })
            .store(in: &cancellables)
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
            repository.deleteReceipt(id: receipt.id)
                .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] in
                    self?.receipts.remove(at: index)
                })
                .store(in: &cancellables)
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
