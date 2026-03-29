// Features/Subscription/Views/SubscriptionView.swift
import SwiftUI

struct SubscriptionView: View {
    @StateObject private var viewModel: SubscriptionViewModel
    private let brand = Color.brand

    init(userId: String) {
        _viewModel = StateObject(wrappedValue: SubscriptionViewModel(userId: userId))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                if viewModel.isLoading {
                    ProgressView("جارٍ التحميل...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // MARK: Active subscription banner
                            if let active = viewModel.activeSubscription {
                                ActiveSubscriptionCard(active: active, brand: brand)
                            } else {
                                NoSubscriptionBanner(brand: brand)
                            }

                            // MARK: Plans
                            if !viewModel.plans.isEmpty {
                                VStack(alignment: .trailing, spacing: 12) {
                                    Text("خطط الاشتراك المتاحة")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .padding(.horizontal, 16)

                                    ForEach(viewModel.plans) { plan in
                                        PlanCard(
                                            plan: plan,
                                            isCurrentPlan: viewModel.activeSubscription?.planId == plan.id,
                                            brand: brand
                                        ) {
                                            viewModel.confirmSubscribe(to: plan)
                                        }
                                        .padding(.horizontal, 16)
                                    }
                                }
                            } else {
                                Text("لا توجد خطط اشتراك متاحة حالياً")
                                    .foregroundColor(.secondary)
                                    .padding(.top, 40)
                            }
                        }
                        .padding(.vertical, 20)
                    }
                }

                // MARK: Subscribing overlay
                if viewModel.isSubscribing {
                    Color.black.opacity(0.35).ignoresSafeArea()
                    VStack(spacing: 16) {
                        ProgressView().scaleEffect(1.4).tint(.white)
                        Text("جارٍ معالجة الاشتراك...")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    .padding(30)
                    .background(brand)
                    .cornerRadius(16)
                }
            }
            .navigationTitle("الاشتراكات")
            .navigationBarTitleDisplayMode(.inline)
            .task { await viewModel.load() }
            // MARK: Confirm sheet
            .confirmationDialog(
                confirmTitle,
                isPresented: $viewModel.showConfirmSheet,
                titleVisibility: .visible
            ) {
                Button("تأكيد الاشتراك") {
                    Task { await viewModel.subscribe() }
                }
                Button("إلغاء", role: .cancel) {}
            } message: {
                if let plan = viewModel.selectedPlan {
                    Text("سيتم خصم \(plan.formattedPrice) من رصيد محفظتك")
                }
            }
            // MARK: Error alert
            .alert("خطأ", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("حسناً") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            // MARK: Success alert
            .alert("تم بنجاح ✓", isPresented: Binding(
                get: { viewModel.successMessage != nil },
                set: { if !$0 { viewModel.successMessage = nil } }
            )) {
                Button("حسناً") { viewModel.successMessage = nil }
            } message: {
                Text(viewModel.successMessage ?? "")
            }
        }
    }

    private var confirmTitle: String {
        guard let plan = viewModel.selectedPlan else { return "تأكيد الاشتراك" }
        let action = viewModel.activeSubscription != nil ? "تجديد الاشتراك" : "الاشتراك"
        return "\(action) في \"\(plan.name)\""
    }
}

// MARK: - Active subscription card
private struct ActiveSubscriptionCard: View {
    let active: ActiveSubscription
    let brand: Color

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .font(.title2)
                Text("اشتراك نشط")
                    .font(.headline)
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(brand)

            // Body
            VStack(spacing: 12) {
                InfoRow(label: "تاريخ الانتهاء", value: active.formattedEndDate)
                Divider()
                InfoRow(label: "الإعلانات المستخدمة", value: "\(active.usedAds) / \(active.maxAds)")
                Divider()

                // Ads usage progress bar
                VStack(alignment: .trailing, spacing: 6) {
                    Text("الإعلانات المتبقية: \(active.remainingAds)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(brand)
                                .frame(
                                    width: active.maxAds > 0
                                        ? geo.size.width * CGFloat(active.usedAds) / CGFloat(active.maxAds)
                                        : 0,
                                    height: 8
                                )
                        }
                    }
                    .frame(height: 8)
                }
            }
            .padding(16)
            .background(Color.cardBackground)
        }
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
        .padding(.horizontal, 16)
    }
}

// MARK: - No subscription banner
private struct NoSubscriptionBanner: View {
    let brand: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.title2)
                .foregroundColor(.orange)
            VStack(alignment: .leading, spacing: 2) {
                Text("لا يوجد اشتراك نشط")
                    .font(.headline)
                Text("اشترك في إحدى الخطط أدناه لتفعيل ميزة الإعلانات")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(14)
        .background(Color.orange.opacity(0.08))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.orange.opacity(0.3), lineWidth: 1))
        .padding(.horizontal, 16)
    }
}

// MARK: - Plan card
private struct PlanCard: View {
    let plan: SubscriptionPlan
    let isCurrentPlan: Bool
    let brand: Color
    let onSubscribe: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Top accent bar
            Rectangle()
                .fill(isCurrentPlan ? Color.green : brand)
                .frame(height: 4)

            VStack(spacing: 14) {
                // Plan name + current badge
                HStack {
                    if isCurrentPlan {
                        Text("خطتك الحالية")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.green)
                            .cornerRadius(6)
                    }
                    Spacer()
                    Text(plan.name)
                        .font(.title3)
                        .fontWeight(.bold)
                }

                Divider()

                // Details grid
                HStack(spacing: 0) {
                    PlanDetailCell(icon: "clock.fill",       label: "المدة",     value: plan.formattedDuration)
                    Divider().frame(width: 1, height: 44)
                    PlanDetailCell(icon: "megaphone.fill",   label: "الإعلانات", value: "\(plan.maxAds) إعلان")
                    Divider().frame(width: 1, height: 44)
                    PlanDetailCell(icon: "banknote.fill",    label: "السعر",     value: plan.formattedPrice)
                }

                // Subscribe button
                Button(action: onSubscribe) {
                    Text(isCurrentPlan ? "تجديد الاشتراك" : "اشترك الآن")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(isCurrentPlan ? Color.green : brand)
                        .cornerRadius(10)
                }
            }
            .padding(16)
            .background(Color.cardBackground)
        }
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.07), radius: 6, x: 0, y: 2)
    }
}

private struct PlanDetailCell: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
            Spacer()
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}
