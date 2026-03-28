import SwiftUI

struct EventHallStep4View<FormData: PropertyForm>: View {
    @StateObject private var viewModel: EventHallStep4ViewModel<FormData>
    let onBack: () -> Void
    let onNext: (FormData) -> Void

    private let brand = Color(red: 136/255, green: 65/255, blue: 122/255)

    init(form: FormData, onBack: @escaping () -> Void, onNext: @escaping (FormData) -> Void) {
        _viewModel = StateObject(wrappedValue: EventHallStep4ViewModel(form: form))
        self.onBack = onBack
        self.onNext = onNext
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: Header
                VStack(spacing: 0) {
                    HStack {
                        BackButton(action: onBack)
                        Spacer()
                        Text("تواريخ عدم التوفر")
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
                    VStack(spacing: 20) {

                        // MARK: Date range pickers
                        VStack(spacing: 12) {
                            Text("اختر نطاق التواريخ")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .trailing)

                            // Start date
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("تاريخ البداية")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                DatePicker(
                                    "",
                                    selection: $viewModel.startDate,
                                    displayedComponents: [.date]
                                )
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .tint(brand)
                                .padding(.horizontal, 8)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.15), lineWidth: 1))
                            }

                            // End date
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("تاريخ النهاية")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                DatePicker(
                                    "",
                                    selection: $viewModel.endDate,
                                    in: viewModel.startDate...,
                                    displayedComponents: [.date]
                                )
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .tint(brand)
                                .padding(.horizontal, 8)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.15), lineWidth: 1))
                            }
                        }
                        .padding(.horizontal, 16)

                        // MARK: Generate range button
                        Button {
                            viewModel.generateRange()
                        } label: {
                            HStack {
                                Image(systemName: "calendar.badge.plus")
                                Text("إضافة النطاق")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(brand)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 16)

                        // MARK: Per-date morning/evening list
                        if !viewModel.entries.isEmpty {
                            VStack(alignment: .trailing, spacing: 10) {
                                Text("التواريخ المضافة")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .trailing)

                                ForEach($viewModel.entries) { $entry in
                                    DatePeriodRow(
                                        entry: $entry,
                                        brand: brand,
                                        formattedDate: viewModel.formattedDate(entry.date),
                                        onDelete: { viewModel.removeEntry(entry) }
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.vertical, 16)
                }

                NextButton(
                    action: {
                        viewModel.save()
                        onNext(viewModel.form)
                    },
                    isDisabled: false
                )
            }
            .background(Color.white)
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Per-date row with morning/evening toggles
private struct DatePeriodRow: View {
    @Binding var entry: DateAvailabilityEntry
    let brand: Color
    let formattedDate: String
    let onDelete: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Date header row
            HStack {
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red.opacity(0.8))
                }
                Spacer()
                Text(formattedDate)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 14)
            .padding(.top, 10)
            .padding(.bottom, 8)

            Divider().padding(.horizontal, 14)

            // Morning / Evening toggles
            HStack(spacing: 0) {
                PeriodToggleButton(
                    label: "صباح",
                    icon: "sun.max.fill",
                    isOn: $entry.morning,
                    brand: brand
                )

                Divider().frame(width: 1, height: 36)

                PeriodToggleButton(
                    label: "مساء",
                    icon: "moon.fill",
                    isOn: $entry.evening,
                    brand: brand
                )
            }
            .padding(.bottom, 10)
        }
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.15), lineWidth: 1))
    }
}

private struct PeriodToggleButton: View {
    let label: String
    let icon: String
    @Binding var isOn: Bool
    let brand: Color

    var body: some View {
        Button {
            isOn.toggle()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.subheadline)
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.medium)
                if isOn {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .fontWeight(.bold)
                }
            }
            .foregroundColor(isOn ? .white : brand)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isOn ? brand : Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
