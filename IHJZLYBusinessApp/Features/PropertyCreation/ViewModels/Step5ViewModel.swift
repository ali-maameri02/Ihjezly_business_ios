// Features/PropertyCreation/ViewModels/Step5ViewModel.swift
import Foundation
import Combine
import PhotosUI
import UIKit

@MainActor
final class Step5ViewModel<FormData: PropertyForm>: ObservableObject {
    @Published var form: FormData
    @Published var rawBase64Images: [String] = []
    @Published var imageDataList: [Data] = []
    @Published var videoUrl: String = "" {
        didSet {
            form.videoUrl = videoUrl
            validate()
        }
    }
    @Published var mainImageIndex: Int?
    @Published var validationErrors: [ValidationError] = []

    init(form: FormData) {
        self.form = form
        self.rawBase64Images = form.images.compactMap { img in
            if let range = img.url.range(of: ",") {
                return String(img.url[range.upperBound...])
            }
            return img.url
        }
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
        form.images = rawBase64Images.enumerated().map { index, b64 in
            let fullURL = "data:image/jpeg;base64,\(b64)"
            return ImageUpload(url: fullURL, isMain: (mainImageIndex ?? 0) == index)
        }
        form.videoUrl = videoUrl
    }

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
}
