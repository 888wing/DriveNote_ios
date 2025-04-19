import SwiftUI

struct ReceiptGalleryView: View {
    @ObservedObject var viewModel: ReceiptGalleryViewModel
    @State private var showPreview: Bool = false
    @State private var selectedImage: UIImage?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.receipts) { receipt in
                    Button(action: {
                        selectedImage = viewModel.loadImage(for: receipt)
                        showPreview = true
                    }) {
                        HStack {
                            if let thumbnail = viewModel.loadThumbnail(for: receipt) {
                                Image(uiImage: thumbnail)
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(8)
                            } else {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 60, height: 60)
                                    .overlay(Image(systemName: "doc.text.image").foregroundColor(.gray))
                            }
                            VStack(alignment: .leading) {
                                Text(receipt.uploadTimestamp, style: .date)
                                    .font(.headline)
                                Text(receipt.ocrStatus.capitalized)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .onDelete(perform: viewModel.deleteReceipts)
            }
            .navigationTitle("Receipt Gallery")
            .toolbar {
                EditButton()
            }
            .sheet(isPresented: $showPreview) {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .padding()
                }
            }
        }
    }
}
