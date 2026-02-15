import SwiftUI
import Photos

struct Step5View<FormData: PropertyForm>: View {
    @StateObject private var viewModel: Step5ViewModel<FormData>
    let onNext: (FormData) -> Void
    
    init(form: FormData, onNext: @escaping (FormData) -> Void) {
        _viewModel = StateObject(wrappedValue: Step5ViewModel(form: form))
        self.onNext = onNext
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 0) {
                    HStack {
                        BackButton(action: {})
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
                    // Image gallery (reuse existing implementation)
                    if !viewModel.rawBase64Images.isEmpty {
                        ScrollView(.horizontal) {
                            HStack {
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
                        }
                        .frame(height: 100)
                    }
                    
                    // Add image button
                    if viewModel.rawBase64Images.isEmpty {
                        Button(action: { viewModel.selectMainImage() }) {
                            // Placeholder UI
                        }
                    }
                    
                    // Video URL field
                    VStack(alignment: .leading) {
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
        }
    }
}
