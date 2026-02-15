// Features/HotelRoom/ViewModels/HotelRoomStep5ViewModel.swift

import Foundation
import Combine
import PhotosUI
import UIKit

@MainActor
final class HotelRoomStep5ViewModel: ObservableObject {
    @Published var form: HotelRoomForm
    @Published var rawBase64Images: [String] = [] // Raw base64 for display
    @Published var imageDataList: [Data] = [] // Original image data for upload
    @Published var videoUrl: String = "" {
        didSet {
            form.videoUrl = videoUrl
            validate()
        }
    }
    @Published var mainImageIndex: Int?
    @Published var validationErrors: [ValidationError] = []

    init(form: HotelRoomForm) {
        self.form = form
        // Extract RAW base64 from existing ImageUploads
        self.rawBase64Images = form.images.compactMap { img in
            if let range = img.url.range(of: ",") {
                return String(img.url[range.upperBound...])
            }
            return img.url
        }
        // Also try to restore image data if possible (this is a best effort)
        self.imageDataList = form.images.compactMap { img in
            if let range = img.url.range(of: ",") {
                let rawBase64 = String(img.url[range.upperBound...])
                return Data(base64Encoded: rawBase64)
            }
            return Data(base64Encoded: img.url)
        }
        self.mainImageIndex = form.images.firstIndex { $0.isMain }
        self.videoUrl = form.videoUrl
        validate()
    }

    var isNextDisabled: Bool { !validationErrors.isEmpty }

    func validate() {
        validationErrors = ValidationManager.shared.validateStep5(
            images: rawBase64Images,
            videoUrl: videoUrl.isEmpty ? nil : videoUrl
        )
    }

    func saveImagesAndVideo() {
        // Reconstruct ImageUpload with full data URLs
        form.images = rawBase64Images.enumerated().map { index, b64 in
            let fullURL = "data:image/jpeg;base64,\(b64)"
            return ImageUpload(url: fullURL, isMain: (mainImageIndex ?? 0) == index)
        }
        form.videoUrl = videoUrl
    }

    // MARK: - Image Selection
    func selectMainImage() {
        ImagePicker.shared.selectImage { [weak self] base64, imageData in
            guard let self = self else { return }
            if let range = base64.range(of: ",") {
                let raw = String(base64[range.upperBound...])
                self.rawBase64Images.append(raw)
                if let imageData = imageData {
                    self.imageDataList.append(imageData)
                }
                self.mainImageIndex = 0
            }
            self.validate()
        }
    }

    func selectMainImage(at index: Int) {
        mainImageIndex = index
    }

    func addMoreImages() {
        ImagePicker.shared.selectImage(multiple: true) { [weak self] base64, imageData in
            guard let self = self else { return }
            if let range = base64.range(of: ",") {
                let raw = String(base64[range.upperBound...])
                if self.rawBase64Images.count < 5 {
                    self.rawBase64Images.append(raw)
                    if let imageData = imageData {
                        self.imageDataList.append(imageData)
                    }
                    if self.mainImageIndex == nil {
                        self.mainImageIndex = 0
                    }
                }
            }
            self.validate()
        }
    }

    func deleteImage(at index: Int) {
        rawBase64Images.remove(at: index)
        if index < imageDataList.count {
            imageDataList.remove(at: index)
        }
        if mainImageIndex == index {
            mainImageIndex = rawBase64Images.isEmpty ? nil : 0
        } else if mainImageIndex != nil && index < mainImageIndex! {
            mainImageIndex! -= 1
        }
        validate()
    }

    func deleteAllImages() {
        rawBase64Images.removeAll()
        imageDataList.removeAll()
        mainImageIndex = nil
        validate()
    }
}

// MARK: - Image Picker
class ImagePicker: NSObject, PHPickerViewControllerDelegate {
    static let shared = ImagePicker()
    private var completion: ((String, Data?) -> Void)?
    private var multiple = false
    private var selectedImages: [(String, Data)] = []

    private override init() {}

    func selectImage(multiple: Bool = false, completion: @escaping (String, Data?) -> Void) {
        self.completion = completion
        self.multiple = multiple
        self.selectedImages = []
        
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = multiple ? 5 : 1
        config.preferredAssetRepresentationMode = .current
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(picker, animated: true)
        }
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        if results.isEmpty {
            return
        }
        
        let group = DispatchGroup()
        
        for result in results {
            group.enter()
            
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                    defer { group.leave() }
                    
                    guard let self = self,
                          let image = image as? UIImage,
                          let imageData = image.jpegData(compressionQuality: 0.7) else { return }
                    
                    let base64 = "data:image/jpeg;base64,\(imageData.base64EncodedString())"
                    
                    DispatchQueue.main.async {
                        self.selectedImages.append((base64, imageData))
                        
                        if !self.multiple {
                            self.completion?(base64, imageData)
                        }
                    }
                }
            } else {
                group.leave()
            }
        }
        
        if multiple {
            group.notify(queue: .main) { [weak self] in
                guard let self = self else { return }
                // For multiple selection, call completion for each image
                for (base64, imageData) in self.selectedImages {
                    self.completion?(base64, imageData)
                }
            }
        }
    }
}
