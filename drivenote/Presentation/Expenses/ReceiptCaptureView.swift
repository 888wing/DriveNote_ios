import SwiftUI
import PhotosUI

struct ReceiptCaptureView: View {
    @State private var showImagePicker = false
    @State private var showPhotoLibrary = false
    @State private var inputImage: UIImage?
    @State private var receiptImage: Image?
    @State private var isSaving = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    let onSave: (UIImage) -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            if let receiptImage = receiptImage {
                receiptImage
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .cornerRadius(16)
                    .padding()
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [6]))
                    .foregroundColor(Color.accentColor)
                    .frame(height: 200)
                    .overlay(
                        VStack {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Color.accentColor)
                            Text("Tap to add receipt photo")
                                .foregroundColor(.secondary)
                        }
                    )
                    .onTapGesture {
                        showImagePicker = true
                    }
            }

            HStack(spacing: 16) {
                Button(action: { showImagePicker = true }) {
                    Label("Camera", systemImage: "camera")
                }
                .buttonStyle(.borderedProminent)
                .disabled(isSaving)
                
                Button(action: { showPhotoLibrary = true }) {
                    Label("Photo Library", systemImage: "photo.on.rectangle")
                }
                .buttonStyle(.bordered)
                .disabled(isSaving)
            }

            if receiptImage != nil {
                Button(action: saveReceipt) {
                    Label("Save Receipt", systemImage: "tray.and.arrow.down")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 16)
                .disabled(isSaving)
            }
        }
        .padding()
        .photosPicker(isPresented: $showPhotoLibrary, selection: .constant(nil), matching: .images)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $inputImage)
        }
        .onChange(of: inputImage) { _ in loadImage() }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func loadImage() {
        guard let inputImage = inputImage else { return }
        receiptImage = Image(uiImage: inputImage)
    }
    
    private func saveReceipt() {
        guard let inputImage = inputImage else { return }
        isSaving = true
        onSave(inputImage)
        isSaving = false
        alertMessage = "Receipt saved successfully."
        showAlert = true
        receiptImage = nil
        inputImage = nil
    }
}

// MARK: - ImagePicker (UIKit Wrapper)
struct ImagePicker: UIViewControllerRepresentable {
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
