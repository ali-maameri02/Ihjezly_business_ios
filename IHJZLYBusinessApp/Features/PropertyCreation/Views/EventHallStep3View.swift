import SwiftUI

struct EventHallStep3View<FormData: PropertyForm>: View {
    @StateObject private var viewModel: EventHallStep3ViewModel<FormData>
    let onBack: () -> Void
    let onNext: (FormData) -> Void

    private let brand = Color(red: 136/255, green: 65/255, blue: 122/255)

    init(form: FormData, onBack: @escaping () -> Void, onNext: @escaping (FormData) -> Void) {
        _viewModel = StateObject(wrappedValue: EventHallStep3ViewModel(form: form))
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
                        Text("الضيوف والمميزات")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                    Divider()
                        .background(brand)
                        .frame(height: 2)
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                }
                .background(Color.white)
                .shadow(radius: 1)

                ScrollView {
                    VStack(spacing: 24) {

                        // MARK: Guest capacity
                        VStack(alignment: .leading, spacing: 12) {
                            Text("عدد الضيوف")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .trailing)

                            HStack {
                                Spacer()
                                Button {
                                    if viewModel.maxGuests > 1 { viewModel.maxGuests -= 1 }
                                    viewModel.validate()
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(brand)
                                }

                                Text("\(viewModel.maxGuests)")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .frame(minWidth: 48)
                                    .multilineTextAlignment(.center)

                                Button {
                                    viewModel.maxGuests += 1
                                    viewModel.validate()
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(brand)
                                }
                                Spacer()
                            }
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2), lineWidth: 0.5))
                        }
                        .padding(.horizontal, 16)

                        // MARK: Basic features
                        VStack(alignment: .trailing, spacing: 12) {
                            Text("المميزات الأساسية")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .trailing)

                            ForEach(Feature.allCases, id: \.self) { feature in
                                FeatureCheckRow(
                                    title: feature.arabicName,
                                    icon: feature.iconName,
                                    isSelected: viewModel.selectedFeatures.contains(feature),
                                    brand: brand
                                ) {
                                    viewModel.toggleFeature(feature)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 16)
                }

                ValidationView(errors: viewModel.validationErrors)
                NextButton(
                    action: {
                        viewModel.saveAndProceed()
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

// MARK: - Feature checkbox row
private struct FeatureCheckRow: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let brand: Color
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .font(.title3)
                    .foregroundColor(isSelected ? brand : .gray)

                Image(systemName: icon)
                    .font(.body)
                    .foregroundColor(isSelected ? brand : .gray)
                    .frame(width: 24)

                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding(12)
            .background(isSelected ? brand.opacity(0.06) : Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? brand.opacity(0.4) : Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
