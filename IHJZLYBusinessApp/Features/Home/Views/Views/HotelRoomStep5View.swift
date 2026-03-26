// Features/HotelRoom/Views/HotelRoomStep5View.swift
import SwiftUI
import Photos

struct HotelRoomStep5View: View {
    @StateObject private var viewModel: HotelRoomStep5ViewModel
    let onBack: () -> Void
    let onNext: (HotelRoomForm) -> Void

    init(
        form: HotelRoomForm,
        onBack: @escaping () -> Void,
        onNext: @escaping (HotelRoomForm) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: HotelRoomStep5ViewModel(form: form))
        self.onBack = onBack
        self.onNext = onNext
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 0) {
                    HStack {
                        BackButton(action: onBack)
                        Spacer()
                        Text("أضف صور العقار")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    
                    Divider()
                        .background(Color(hex: "#88417A"))
                        .frame(height: 2)
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                }
                .background(Color.white)
                .shadow(radius: 1)
                
                ScrollView {
                    // Image gallery
                    if !viewModel.rawBase64Images.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(viewModel.rawBase64Images.enumerated()), id: \.offset) { index, url in
                                    let fullURL = "data:image/jpeg;base64,\(url)"
                                    ImagePreview(
                                        url: fullURL,
                                        isSelected: viewModel.mainImageIndex == index,
                                        onSelect: { viewModel.selectMainImage(at: index) },
                                        onDelete: { viewModel.deleteImage(at: index) }
                                    )
                                    .frame(width: 100, height: 100)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                        }
                        .frame(height: 100)
                    }
                    
                    // Add image placeholder
                    if viewModel.rawBase64Images.isEmpty {
                        Button(action: { viewModel.selectMainImage() }) {
                            ZStack {
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(width: 300, height: 200)
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                Image(systemName: "photo")
                                    .font(.system(size: 48))
                                    .foregroundColor(Color.gray.opacity(0.5))
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(Color(hex: "#88417A"))
                                    .offset(y: -20)
                            }
                            .frame(width: 300, height: 200)
                        }
                    }
                    
                    // Buttons
                    VStack(spacing: 12) {
                        Button("أضف المزيد") { viewModel.addMoreImages() }
                            .frame(height: 52)
                            .background(Color(hex: "#88417A"))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            
                        if !viewModel.rawBase64Images.isEmpty {
                            Button("حذف كل الصور") { viewModel.deleteAllImages() }
                                .frame(height: 52)
                                .background(Color(hex: "#88417A"))
                                .cornerRadius(12)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Video URL
                    VStack(alignment: .leading, spacing: 8) {
                        Text("رابط فيديو العقار")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        TextField("الرابط", text: $viewModel.videoUrl)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2), lineWidth: 0.5))
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 16)
                
                ValidationView(errors: viewModel.validationErrors)

                NextButton(
                    action: {
                        viewModel.saveImagesAndVideo()
                        onNext(viewModel.form)
                    },
                    isDisabled: viewModel.isNextDisabled
                )
            }
            .background(Color.white)
            .navigationBarHidden(true)
            .onAppear { requestPhotoAccess() }
        }
    }
    
    private func requestPhotoAccess() {
        PHPhotoLibrary.requestAuthorization { _ in }
    }
}
