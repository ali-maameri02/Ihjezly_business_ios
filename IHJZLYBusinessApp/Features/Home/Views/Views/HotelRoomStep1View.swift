// Features/HotelRoom/Views/HotelRoomStep1View.swift

import SwiftUI

struct HotelRoomStep1View: View {
    @StateObject private var viewModel: HotelRoomStep1ViewModel
    @Environment(\.dismiss) private var dismiss
    let onBack: (() -> Void)?
    let onNext: () -> Void

    @State private var showStateSheet = false
    @State private var showDistrictSheet = false

    init(
        viewModel: HotelRoomStep1ViewModel,
        onBack: (() -> Void)? = nil,
        onNext: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onBack = onBack
        self.onNext = onNext
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // FIXED HEADER
                VStack(spacing: 0) {
                    HStack {
                        if let onBack = onBack {
                            BackButton(action: onBack)
                        } else {
                            BackButton(action: { dismiss() })
                        }
                        Spacer()
                        Text("معلومات العقار")
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
                .shadow(radius: 1) // Optional: subtle shadow
                
                // SCROLLABLE CONTENT
                ScrollView {
                    VStack(spacing: 24) {
                        // اسم العقار
                        VStack(alignment: .leading, spacing: 4) {
                            Text("اسم العقار")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            TextField("", text: $viewModel.title) // Instead of $viewModel.form.title
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                                )
                        }
                        .frame(maxWidth: .infinity)

                        // المدينة
                        VStack(alignment: .leading, spacing: 4) {
                            Text("المدينة")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            HStack {
                                Text(viewModel.state.isEmpty ? "المدينة" : viewModel.state)
                                    .foregroundColor(viewModel.form.location.state.isEmpty ? .secondary : .primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Spacer(minLength: 8)
                                Text("▼")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                            )
                            .onTapGesture {
                                if !viewModel.hasLoadedStates {
                                    Task { [weak viewModel] in
                                        guard let viewModel = viewModel else { return }
                                        await viewModel.loadStates()
                                        await MainActor.run {
                                            showStateSheet = true
                                        }
                                    }
                                } else {
                                    showStateSheet = true
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .frame(maxWidth: .infinity)

                        // الحي
                        VStack(alignment: .leading, spacing: 4) {
                            Text("الحي")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            HStack {
                                Text(viewModel.city.isEmpty ? "الحي" : viewModel.city)                                    .foregroundColor(viewModel.form.location.city.isEmpty ? .secondary : .primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Spacer(minLength: 8)
                                Text("▼")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                            )
                            .onTapGesture {
                                if viewModel.form.location.state.isEmpty {
                                    viewModel.errorMessage = "اختر المدينة أولاً"
                                    viewModel.isErrorAlertPresented = true
                                    return
                                }
                                if viewModel.districts.isEmpty {
                                    Task { [weak viewModel] in
                                        guard let viewModel = viewModel else { return }
                                        await viewModel.loadDistricts(for: viewModel.form.location.state)
                                        await MainActor.run {
                                            showDistrictSheet = true
                                        }
                                    }
                                } else {
                                    showDistrictSheet = true
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .frame(maxWidth: .infinity)

                        // وصف العقار
                        VStack(alignment: .leading, spacing: 4) {
                            Text("وصف العقار")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            TextField("", text: $viewModel.description) // Instead of $viewModel.form.description
                                .multilineTextAlignment(.leading)
                                .lineLimit(nil)
                                .frame(height: 40)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                                )
                        }
                        .frame(maxWidth: .infinity)

                        // Character counter
                        HStack {
                            Text("\(viewModel.form.description.count)/500 : عدد الأحرف")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
                
                ValidationView(errors: viewModel.validationErrors)

                NextButton(
                    action: onNext,
                    isDisabled: viewModel.isNextDisabled
                )
            }
            .background(Color.white)
            .navigationBarHidden(true)
            .alert("خطأ", isPresented: $viewModel.isErrorAlertPresented) {
                Button("موافق") {
                    viewModel.isErrorAlertPresented = false
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .sheet(isPresented: $showStateSheet) {
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 4)
                        .padding(.top, 8)
                    List(viewModel.states, id: \.self) { state in
                        Button(state) {
                            viewModel.form.location.state = state
                            Task { [weak viewModel] in
                                guard let viewModel = viewModel else { return }
                                await viewModel.loadDistricts(for: state)
                            }
                            showStateSheet = false
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                    }
                    .listStyle(PlainListStyle())
                }
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showDistrictSheet) {
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 4)
                        .padding(.top, 8)
                    List(viewModel.districts, id: \.self) { district in
                        Button(district) {
                            viewModel.form.location.city = district
                            showDistrictSheet = false
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                    }
                    .listStyle(PlainListStyle())
                }
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
            }
        }
    }
}
