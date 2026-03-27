import SwiftUI
import Photos

struct Step5View<FormData: PropertyForm>: View {
    @StateObject private var viewModel: Step5ViewModel<FormData>
    let onBack: () -> Void
    let onNext: (FormData) -> Void

    init(form: FormData, onBack: @escaping () -> Void, onNext: @escaping (FormData) -> Void) {
        _viewModel = StateObject(wrappedValue: Step5ViewModel(form: form))
        self.onBack = onBack
        self.onNext = onNext
    }

    private let brand = Color(red: 136/255, green: 65/255, blue: 122/255)

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
                    VStack(spacing: 20) {

                        // ── Image grid ──────────────────────────────
                        if viewModel.rawBase64Images.isEmpty {
                            // Empty state — big tap target
                            Button(action: { viewModel.pickImages() }) {
                                VStack(spacing: 12) {
                                    Image(systemName: "photo.badge.plus")
                                        .font(.system(size: 48))
                                        .foregroundColor(brand)
                                    Text("اضغط لإضافة صور")
                                        .font(.headline)
                                        .foregroundColor(brand)
                                    Text("يجب إضافة صورة واحدة على الأقل")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 180)
                                .background(brand.opacity(0.06))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(brand.opacity(0.3),
                                                style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                                )
                            }
                            .padding(.horizontal, 16)
                        } else {
                            // Images row
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(Array(viewModel.rawBase64Images.enumerated()), id: \.offset) { index, b64 in
                                        ImagePreview(
                                            url: "data:image/jpeg;base64,\(b64)",
                                            isSelected: viewModel.mainImageIndex == index,
                                            onSelect: { viewModel.selectMainImage(at: index) },
                                            onDelete: { viewModel.deleteImage(at: index) }
                                        )
                                        .frame(width: 100, height: 100)
                                    }

                                    // Add more button
                                    Button(action: { viewModel.pickImages() }) {
                                        VStack(spacing: 6) {
                                            Image(systemName: "plus")
                                                .font(.title2)
                                                .foregroundColor(brand)
                                            Text("إضافة")
                                                .font(.caption)
                                                .foregroundColor(brand)
                                        }
                                        .frame(width: 100, height: 100)
                                        .background(brand.opacity(0.06))
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(brand.opacity(0.3),
                                                        style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                                        )
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                            .frame(height: 110)

                            Text("اضغط على صورة لتعيينها كصورة رئيسية")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        // ── Video URL ───────────────────────────────
                        VStack(alignment: .leading, spacing: 8) {
                            Text("رابط فيديو العقار (اختياري)")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            TextField("https://...", text: $viewModel.videoUrl)
                                .keyboardType(.URL)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 0.5))
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 16)
                }

                ValidationView(errors: viewModel.validationErrors)
                NextButton(
                    action: { viewModel.saveImagesAndVideo(); onNext(viewModel.form) },
                    isDisabled: viewModel.isNextDisabled
                )
            }
            .background(Color.white)
            .navigationBarHidden(true)
            .onAppear { PHPhotoLibrary.requestAuthorization { _ in } }
        }
    }
}
