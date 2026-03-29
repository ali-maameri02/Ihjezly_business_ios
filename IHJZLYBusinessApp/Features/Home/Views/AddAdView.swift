// Features/Home/Views/AddAdView.swift
import SwiftUI

struct AddAdView: View {
    @StateObject private var viewModel = AddAdViewModel()
    @State private var showSubscription = false
    private let brand = Color.brand

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView("جارٍ التحميل...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 16) {

                        // MARK: Subscription status banner
                        subscriptionBanner

                        // MARK: Properties
                        if viewModel.properties.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "building.2")
                                    .font(.system(size: 56))
                                    .foregroundColor(.gray.opacity(0.5))
                                Text("لا توجد عقارات لديك بعد")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Text("أضف عقاراً أولاً من تبويب \"إضافة وحدة\"")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 60)
                        } else {
                            ForEach(viewModel.properties) { property in
                                AdPropertyRow(
                                    property: property,
                                    isToggling: viewModel.togglingId == property.id,
                                    hasSubscription: viewModel.activeSubscription != nil,
                                    brand: brand
                                ) {
                                    Task { await viewModel.toggleAd(for: property) }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                    .padding(.vertical, 16)
                }
            }
        }
        .task { await viewModel.load() }
        .sheet(isPresented: $showSubscription) {
            SubscriptionView(userId: currentUserId())
                .onDisappear { Task { await viewModel.load() } }
        }
        .alert("خطأ", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("حسناً") { viewModel.errorMessage = nil }
            if viewModel.errorMessage?.contains("اشتراك") == true {
                Button("اشترك الآن") {
                    viewModel.errorMessage = nil
                    showSubscription = true
                }
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .alert("تم بنجاح ✓", isPresented: Binding(
            get: { viewModel.successMessage != nil },
            set: { if !$0 { viewModel.successMessage = nil } }
        )) {
            Button("حسناً") { viewModel.successMessage = nil }
        } message: {
            Text(viewModel.successMessage ?? "")
        }
    }

    // MARK: Subscription banner
    @ViewBuilder
    private var subscriptionBanner: some View {
        if let active = viewModel.activeSubscription {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                VStack(alignment: .leading, spacing: 2) {
                    Text("اشتراك نشط")
                        .font(.subheadline).fontWeight(.semibold).foregroundColor(.white)
                    Text("الإعلانات المتبقية: \(active.remainingAds) / \(active.maxAds)")
                        .font(.caption).foregroundColor(.white.opacity(0.85))
                }
                Spacer()
                Button("تجديد") { showSubscription = true }
                    .font(.caption).fontWeight(.bold)
                    .foregroundColor(brand)
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(Color.cardBackground)
                    .cornerRadius(8)
            }
            .padding(14)
            .background(brand)
            .cornerRadius(12)
            .padding(.horizontal, 16)
        } else {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.title2).foregroundColor(.orange)
                VStack(alignment: .leading, spacing: 2) {
                    Text("لا يوجد اشتراك نشط")
                        .font(.subheadline).fontWeight(.semibold)
                    Text("اشترك لتتمكن من تفعيل الإعلانات")
                        .font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                Button("اشترك") { showSubscription = true }
                    .font(.subheadline).fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(brand)
                    .cornerRadius(10)
            }
            .padding(14)
            .background(Color.orange.opacity(0.07))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.orange.opacity(0.3), lineWidth: 1))
            .padding(.horizontal, 16)
        }
    }

    private func currentUserId() -> String {
        guard let token = UserDefaults.standard.string(forKey: "auth_token") else { return "" }
        let parts = token.components(separatedBy: ".")
        guard parts.count == 3 else { return "" }
        var base64 = parts[1]
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let r = base64.count % 4
        if r > 0 { base64 += String(repeating: "=", count: 4 - r) }
        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return "" }
        return json["sub"] as? String ?? json["nameid"] as? String ?? ""
    }
}

// MARK: - Property row with ad toggle
private struct AdPropertyRow: View {
    let property: MyProperty
    let isToggling: Bool
    let hasSubscription: Bool
    let brand: Color
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Ad status indicator
            Circle()
                .fill(property.isAd ? brand : Color.gray.opacity(0.3))
                .frame(width: 10, height: 10)

            VStack(alignment: .trailing, spacing: 4) {
                Text(property.title)
                    .font(.subheadline).fontWeight(.semibold)
                    .multilineTextAlignment(.trailing)
                HStack(spacing: 8) {
                    Text(property.statusLabel)
                        .font(.caption2).fontWeight(.semibold)
                        .foregroundColor(property.statusColor)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(property.statusColor.opacity(0.12))
                        .cornerRadius(4)
                    Text("\(property.price, specifier: "%.0f") \(property.currency == "LYD" ? "د.ل" : property.currency)")
                        .font(.caption).foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)

            // Toggle button
            if isToggling {
                ProgressView().frame(width: 80)
            } else {
                Button(action: onToggle) {
                    Text(property.isAd ? "إلغاء الإعلان" : "تفعيل كإعلان")
                        .font(.caption).fontWeight(.bold)
                        .foregroundColor(property.isAd ? .red : .white)
                        .padding(.horizontal, 10).padding(.vertical, 7)
                        .background(property.isAd ? Color.red.opacity(0.1) : brand)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(property.isAd ? Color.red.opacity(0.4) : Color.clear, lineWidth: 1)
                        )
                }
                .disabled(!hasSubscription && !property.isAd)
                .opacity(!hasSubscription && !property.isAd ? 0.4 : 1)
            }
        }
        .padding(14)
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
