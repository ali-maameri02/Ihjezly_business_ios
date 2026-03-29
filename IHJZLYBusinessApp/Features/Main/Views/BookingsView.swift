// Features/Main/Views/BookingsView.swift
import SwiftUI

struct BookingsView: View {
    @StateObject private var viewModel = BookingsViewModel()
    @State private var selectedStatus: BookingStatus = .pending
    private let brand = Color.brand
    private let tabs: [BookingStatus] = [.pending, .confirmed, .lastConfirmed, .rejected, .cancelled, .completed]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                statusTabBar
                contentArea
            }
            .navigationTitle("الحجوزات")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.fetch()
                viewModel.startAutoRefresh()
            }
            .onDisappear { viewModel.stopAutoRefresh() }
            .alert("خطأ", isPresented: .init(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("حسناً") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .alert("تم بنجاح", isPresented: .init(
                get: { viewModel.successMessage != nil },
                set: { if !$0 { viewModel.successMessage = nil } }
            )) {
                Button("حسناً") { viewModel.successMessage = nil }
            } message: {
                Text(viewModel.successMessage ?? "")
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }

    // MARK: - Tab bar
    private var statusTabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tabs, id: \.self) { status in
                    let count = bookings(for: status).count
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { selectedStatus = status }
                    } label: {
                        HStack(spacing: 4) {
                            Text(status.arabicLabel)
                                .font(.subheadline)
                                .fontWeight(selectedStatus == status ? .bold : .regular)
                            if count > 0 {
                                Text("\(count)")
                                    .font(.caption2).fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 5).padding(.vertical, 2)
                                    .background(selectedStatus == status
                                                ? Color.white.opacity(0.35)
                                                : status.swiftColor)
                                    .clipShape(Capsule())
                            }
                        }
                        .foregroundColor(selectedStatus == status ? .white : .primary)
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .background(selectedStatus == status ? status.swiftColor : Color(.systemGray5))
                        .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
        }
        .background(Color.cardBackground)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    // MARK: - Content
    @ViewBuilder
    private var contentArea: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            if viewModel.isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("جارٍ التحميل...")
                        .font(.subheadline).foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                let items = bookings(for: selectedStatus)
                if items.isEmpty {
                    emptyState(for: selectedStatus)
                } else {
                    List {
                        ForEach(items) { booking in
                            BookingRow(
                                booking: booking,
                                isActioning: viewModel.actionInProgressId == booking.id,
                                brand: brand,
                                onAccept: { Task { await viewModel.accept(booking) } },
                                onReject: { Task { await viewModel.reject(booking) } }
                            )
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .refreshable { await viewModel.fetch() }
                }
            }
        }
    }

    private func bookings(for status: BookingStatus) -> [Booking] {
        switch status {
        case .pending:       return viewModel.pending
        case .confirmed:     return viewModel.confirmed
        case .lastConfirmed: return viewModel.lastConfirmed
        case .rejected:      return viewModel.rejected
        case .cancelled:     return viewModel.cancelled
        case .completed:     return viewModel.completed
        }
    }

    @ViewBuilder
    private func emptyState(for status: BookingStatus) -> some View {
        VStack(spacing: 14) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 52))
                .foregroundColor(.gray.opacity(0.4))
            Text("لا توجد حجوزات \(status.arabicLabel)")
                .font(.headline).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Booking row card
private struct BookingRow: View {
    let booking: Booking
    let isActioning: Bool
    let brand: Color
    let onAccept: () -> Void
    let onReject: () -> Void

    @State private var showDetail = false

    var body: some View {
        VStack(spacing: 0) {
            // Header: status badge + client name/phone
            HStack {
                StatusBadge(status: booking.bookingStatus)
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(booking.name).font(.headline)
                    Text(booking.phoneNumber)
                        .font(.caption).foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 14)
            .padding(.bottom, 10)

            Divider().padding(.horizontal, 14)

            // Date cells
            HStack(spacing: 0) {
                InfoCell(icon: "calendar",              label: "من",      value: booking.formattedStartDate)
                Divider().frame(width: 1, height: 36)
                InfoCell(icon: "calendar.badge.checkmark", label: "إلى", value: booking.formattedEndDate)
                Divider().frame(width: 1, height: 36)
                InfoCell(icon: "moon.fill",             label: "الليالي", value: "\(booking.nightsCount)")
            }
            .padding(.vertical, 10)

            Divider().padding(.horizontal, 14)

            // Footer: price always visible; pending also shows accept/reject
            HStack(spacing: 0) {
                // Price — shown for all statuses
                Text(booking.formattedPrice)
                    .font(.title3).fontWeight(.bold)
                    .foregroundColor(brand)
                    .padding(.leading, 14)

                Spacer()

                if booking.bookingStatus == .pending {
                    // Accept / Reject actions
                    if isActioning {
                        ProgressView()
                            .padding(.trailing, 14)
                    } else {
                        HStack(spacing: 8) {
                            Button(action: onReject) {
                                Label("رفض", systemImage: "xmark")
                                    .font(.subheadline).fontWeight(.semibold)
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 14).padding(.vertical, 8)
                                    .background(Color.red.opacity(0.08))
                                    .cornerRadius(8)
                            }
                            Button(action: onAccept) {
                                Label("قبول", systemImage: "checkmark")
                                    .font(.subheadline).fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 14).padding(.vertical, 8)
                                    .background(Color.green)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.trailing, 14)
                    }
                } else {
                    Button("التفاصيل") { showDetail = true }
                        .font(.subheadline)
                        .foregroundColor(brand)
                        .padding(.trailing, 14)
                }
            }
            .padding(.vertical, 10)
        }
        .background(Color.cardBackground)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.06), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $showDetail) {
            BookingDetailSheet(booking: booking)
        }
    }
}

// MARK: - Status badge
private struct StatusBadge: View {
    let status: BookingStatus
    var body: some View {
        Text(status.arabicLabel)
            .font(.caption).fontWeight(.semibold)
            .foregroundColor(status.swiftColor)
            .padding(.horizontal, 10).padding(.vertical, 4)
            .background(status.swiftColor.opacity(0.12))
            .cornerRadius(20)
    }
}

// MARK: - Info cell
private struct InfoCell: View {
    let icon: String
    let label: String
    let value: String
    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: icon).font(.caption).foregroundColor(.secondary)
            Text(value).font(.caption).fontWeight(.semibold)
            Text(label).font(.caption2).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Detail sheet
private struct BookingDetailSheet: View {
    let booking: Booking
    @Environment(\.dismiss) private var dismiss
    private let brand = Color.brand

    var body: some View {
        NavigationStack {
            List {
                Section("معلومات العميل") {
                    DetailRow(label: "الاسم",       value: booking.name)
                    DetailRow(label: "رقم الهاتف",  value: booking.phoneNumber)
                }
                Section("تفاصيل الحجز") {
                    DetailRow(label: "تاريخ البداية",  value: booking.formattedStartDate)
                    DetailRow(label: "تاريخ النهاية",  value: booking.formattedEndDate)
                    DetailRow(label: "عدد الليالي",    value: "\(booking.nightsCount) ليلة")
                    DetailRow(label: "السعر الإجمالي", value: booking.formattedPrice)
                    DetailRow(label: "تاريخ الحجز",    value: booking.formattedReservedAt)
                }
                Section("الحالة") {
                    HStack {
                        Spacer()
                        StatusBadge(status: booking.bookingStatus)
                        Spacer()
                    }
                }
            }
            .navigationTitle("تفاصيل الحجز")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("إغلاق") { dismiss() }
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .presentationDetents([.medium, .large])
    }
}

private struct DetailRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(value).foregroundColor(.primary)
            Spacer()
            Text(label).foregroundColor(.secondary)
        }
    }
}
