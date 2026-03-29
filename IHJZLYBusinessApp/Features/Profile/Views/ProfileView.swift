// Features/Profile/Views/ProfileView.swift
import SwiftUI
import Combine

struct ProfileView: View {
    @StateObject private var viewModel = UserProfileViewModel()
    @State private var showSettings = false
    @State private var showNotifications = false
    @State private var showMyProperties = false
    @State private var showAccountInfo = false
    @State private var showLogoutAlert = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 12) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(Color(hex: "#88417A"))
                        
                        Text(viewModel.currentUser?.fullName ?? "المستخدم")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(viewModel.currentUser?.email ?? "")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 0) {
                        NavigationLink(destination: AccountInfoView(user: viewModel.currentUser)) {
                            ProfileMenuItemContent(icon: "person.fill", title: "معلومات الحساب")
                        }
                        Divider()
                        
                        NavigationLink(destination: MyPropertiesView()) {
                            ProfileMenuItemContent(icon: "building.2.fill", title: "عقاراتي")
                        }
                        Divider()
                        
                        NavigationLink(destination: NotificationsView()) {
                            ProfileMenuItemContent(icon: "bell.fill", title: "الإشعارات")
                        }
                        Divider()
                        
                        NavigationLink(destination: SettingsView()) {
                            ProfileMenuItemContent(icon: "gearshape.fill", title: "الإعدادات")
                        }
                        Divider()
                        
                        Button(action: { showLogoutAlert = true }) {
                            ProfileMenuItemContent(icon: "arrow.right.square.fill", title: "تسجيل الخروج", isDestructive: true)
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("الحساب")
            .alert("تسجيل الخروج", isPresented: $showLogoutAlert) {
                Button("إلغاء", role: .cancel) {}
                Button("تسجيل الخروج", role: .destructive) {
                    logout()
                }
            } message: {
                Text("هل أنت متأكد من تسجيل الخروج؟")
            }
        }
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: "auth_token")
        UserDefaults.standard.synchronize()
        exit(0)
    }
}

struct ProfileMenuItemContent: View {
    let icon: String
    let title: String
    var isDestructive: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(isDestructive ? .red : Color(hex: "#88417A"))
                .frame(width: 24)
            Text(title)
                .foregroundColor(isDestructive ? .red : .primary)
            Spacer()
            Image(systemName: "chevron.left")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding()
    }
}

struct AccountInfoView: View {
    let user: User?
    
    var body: some View {
        List {
            Section("المعلومات الشخصية") {
                HStack {
                    Text("الاسم")
                    Spacer()
                    Text(user?.fullName ?? "-")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("البريد الإلكتروني")
                    Spacer()
                    Text(user?.email ?? "-")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("رقم الهاتف")
                    Spacer()
                    Text(user?.phoneNumber ?? "-")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("الدور")
                    Spacer()
                    Text(user?.displayRole ?? "-")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("حالة التحقق")
                    Spacer()
                    HStack {
                        Text(user?.isVerified == true ? "مفعل" : "غير مفعل")
                            .foregroundColor(user?.isVerified == true ? .green : .orange)
                        Image(systemName: user?.isVerified == true ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                            .foregroundColor(user?.isVerified == true ? .green : .orange)
                    }
                }
            }
        }
        .navigationTitle("معلومات الحساب")
    }
}

struct MyPropertiesView: View {
    @StateObject private var viewModel = MyPropertiesViewModel()
    private let brand = Color(red: 136/255, green: 65/255, blue: 122/255)

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: Filter buttons
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(MyPropertiesViewModel.StatusFilter.allCases) { filter in
                            FilterButton(
                                filter: filter,
                                isSelected: viewModel.selectedFilter == filter,
                                count: viewModel.count(for: filter),
                                brand: brand
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    viewModel.selectedFilter = filter
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .background(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)

                if viewModel.isLoading {
                    Spacer()
                    ProgressView("جارس التحميل...")
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            subscriptionBanner
                                .padding(.top, 12)

                            let filtered = viewModel.filteredProperties
                            if filtered.isEmpty {
                                emptyState
                            } else {
                                ForEach(filtered) { property in
                                    PropertyCard(property: property, brand: brand)
                                        .padding(.horizontal, 16)
                                }
                            }
                        }
                        .padding(.bottom, 24)
                    }
                    .refreshable { await viewModel.load() }
                }
            }

            // MARK: Subscribing overlay
            if viewModel.isSubscribing {
                Color.black.opacity(0.35).ignoresSafeArea()
                VStack(spacing: 16) {
                    ProgressView().scaleEffect(1.4).tint(.white)
                    Text("جارس معالجة الاشتراك...")
                        .foregroundColor(.white)
                        .font(.headline)
                }
                .padding(30)
                .background(brand)
                .cornerRadius(16)
            }
        }
        .navigationTitle("عقاراتي")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
        .sheet(isPresented: $viewModel.showPlansSheet) {
            PlansSheet(viewModel: viewModel, brand: brand)
        }
        .confirmationDialog(
            viewModel.selectedPlan.map { "الاشتراك في \"\($0.name)\"" } ?? "تأكيد الاشتراك",
            isPresented: $viewModel.showConfirmDialog,
            titleVisibility: .visible
        ) {
            Button("تأكيد — خصم \(viewModel.selectedPlan?.formattedPrice ?? "")") {
                Task { await viewModel.subscribe() }
            }
            Button("إلغاء", role: .cancel) {}
        } message: {
            Text("سيتم خصم المبلغ من رصيد محفظتك مباشرةً")
        }
        .alert("خطأ", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("حسناً") { viewModel.errorMessage = nil }
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

    // MARK: Empty state
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "building.2")
                .font(.system(size: 56))
                .foregroundColor(.gray.opacity(0.4))
            Text(viewModel.selectedFilter == .all
                 ? "لا توجد عقارات"
                 : "لا توجد عقارات \(viewModel.selectedFilter.label)")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    // MARK: Subscription banner
    @ViewBuilder
    private var subscriptionBanner: some View {
        if let active = viewModel.activeSubscription {
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                    Text("اشتراك نشط — \(active.formattedEndDate)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                    Button("تجديد") { viewModel.showPlansSheet = true }
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(brand.opacity(0.8))
                        .cornerRadius(8)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(brand)

                HStack(spacing: 0) {
                    Label("\(active.usedAds) مستخدم", systemImage: "megaphone.fill")
                        .font(.caption).frame(maxWidth: .infinity)
                    Divider().frame(height: 20)
                    Label("\(active.remainingAds) متبقي", systemImage: "star.fill")
                        .font(.caption).frame(maxWidth: .infinity)
                    Divider().frame(height: 20)
                    Label("\(active.maxAds) إجمالي", systemImage: "list.number")
                        .font(.caption).frame(maxWidth: .infinity)
                }
                .padding(.vertical, 8)
                .background(Color.white)
            }
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.07), radius: 4, x: 0, y: 2)
            .padding(.horizontal, 16)
        } else {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.title2).foregroundColor(.orange)
                VStack(alignment: .leading, spacing: 2) {
                    Text("لا يوجد اشتراك نشط")
                        .font(.subheadline).fontWeight(.semibold)
                    Text("اشترك لتفعيل ميزة الإعلانات على عقاراتك")
                        .font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                Button("اشترك") { viewModel.showPlansSheet = true }
                    .font(.subheadline).fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(brand).cornerRadius(10)
            }
            .padding(14)
            .background(Color.orange.opacity(0.07))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.orange.opacity(0.3), lineWidth: 1))
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Filter button
private struct FilterButton: View {
    let filter: MyPropertiesViewModel.StatusFilter
    let isSelected: Bool
    let count: Int
    let brand: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(filter.label)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .bold : .regular)
                if count > 0 {
                    Text("\(count)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(isSelected ? brand : .white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(isSelected ? brand.opacity(0.15) : Color.gray.opacity(0.4))
                        .clipShape(Capsule())
                }
            }
            .foregroundColor(isSelected ? brand : .secondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                isSelected
                    ? brand.opacity(0.1)
                    : Color(.systemGray6)
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? brand : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Property card
private struct PropertyCard: View {
    let property: MyProperty
    let brand: Color

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {

            // Image
            ZStack(alignment: .topLeading) {
                if let urlStr = property.mainImageUrl, let url = URL(string: urlStr) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable().scaledToFill()
                        case .failure:
                            imagePlaceholder
                        default:
                            Color.gray.opacity(0.15).overlay(ProgressView())
                        }
                    }
                } else {
                    imagePlaceholder
                }
            }
            .frame(height: 160)
            .clipped()
            .cornerRadius(12, corners: [.topLeft, .topRight])

            // Info
            VStack(alignment: .trailing, spacing: 8) {
                HStack {
                    // Status badge
                    Text(property.statusLabel)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(property.statusColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(property.statusColor.opacity(0.12))
                        .cornerRadius(6)
                    Spacer()
                    Text(property.title)
                        .font(.headline)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(1)
                }

                HStack {
                    Text("\(property.price, specifier: "%.0f") \(property.currency == "LYD" ? "د.ل" : property.currency)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(brand)
                    Spacer()
                    Label("\(property.location.city)، \(property.location.state)", systemImage: "mappin.circle.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                if property.isAd {
                    Label("معلن", systemImage: "megaphone.fill")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(brand)
                        .cornerRadius(6)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
        }
        .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 2)
    }

    private var imagePlaceholder: some View {
        Color.gray.opacity(0.12)
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: 36))
                    .foregroundColor(.gray.opacity(0.4))
            )
    }
}

// MARK: - Plans bottom sheet
private struct PlansSheet: View {
    @ObservedObject var viewModel: MyPropertiesViewModel
    let brand: Color

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if viewModel.plans.isEmpty {
                        ProgressView("جارٍ تحميل الخطط...")
                            .padding(.top, 60)
                    } else {
                        ForEach(viewModel.plans) { plan in
                            PlanRow(
                                plan: plan,
                                isCurrentPlan: viewModel.activeSubscription?.planId == plan.id,
                                brand: brand
                            ) {
                                viewModel.showPlansSheet = false
                                viewModel.selectedPlan = plan
                                viewModel.showConfirmDialog = true
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }
                .padding(.vertical, 16)
            }
            .navigationTitle("خطط الاشتراك")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("إغلاق") { viewModel.showPlansSheet = false }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

private struct PlanRow: View {
    let plan: SubscriptionPlan
    let isCurrentPlan: Bool
    let brand: Color
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .trailing, spacing: 6) {
                HStack {
                    if isCurrentPlan {
                        Text("حالي")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green)
                            .cornerRadius(4)
                    }
                    Spacer()
                    Text(plan.name)
                        .font(.headline)
                }
                HStack(spacing: 16) {
                    Label(plan.formattedDuration, systemImage: "clock")
                    Label("\(plan.maxAds) إعلان", systemImage: "megaphone")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            Spacer()
            Button(action: onTap) {
                Text(isCurrentPlan ? "تجديد" : "اشترك")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(isCurrentPlan ? Color.green : brand)
                    .cornerRadius(10)
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 1)
    }
}

// MARK: - MyProperty model (maps PropertyDto)
struct MyProperty: Identifiable {
    let id: String
    let title: String
    let price: Double
    let currency: String
    let isAd: Bool
    let status: String
    let location: MyPropertyLocation
    let mainImageUrl: String?

    var statusLabel: String {
        switch status {
        case "Pending":  return "قيد المراجعة"
        case "Accepted": return "مقبول"
        case "Refused":  return "مرفوض"
        default:         return status
        }
    }

    var statusColor: Color {
        switch status {
        case "Accepted": return .green
        case "Refused":  return .red
        default:         return .orange
        }
    }
}

struct MyPropertyLocation: Codable {
    let city: String
    let state: String
}

// MARK: - MyPropertiesViewModel
@MainActor
final class MyPropertiesViewModel: ObservableObject {

    // MARK: Status filter
    enum StatusFilter: String, CaseIterable, Identifiable {
        case all      = "all"
        case pending  = "Pending"
        case accepted = "Accepted"
        case refused  = "Refused"

        var id: String { rawValue }

        var label: String {
            switch self {
            case .all:      return "الكل"
            case .pending:  return "طلبات المراجعة"
            case .accepted: return "المقبولة"
            case .refused:  return "المرفوضة"
            }
        }

        var color: Color {
            switch self {
            case .all:      return .primary
            case .pending:  return .orange
            case .accepted: return .green
            case .refused:  return .red
            }
        }
    }

    @Published var properties: [MyProperty] = []
    @Published var selectedFilter: StatusFilter = .all
    @Published var plans: [SubscriptionPlan] = []
    @Published var activeSubscription: ActiveSubscription? = nil
    @Published var selectedPlan: SubscriptionPlan? = nil
    @Published var isLoading = false
    @Published var isSubscribing = false
    @Published var showPlansSheet = false
    @Published var showConfirmDialog = false
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil

    var filteredProperties: [MyProperty] {
        guard selectedFilter != .all else { return properties }
        return properties.filter { $0.status == selectedFilter.rawValue }
    }

    func count(for filter: StatusFilter) -> Int {
        guard filter != .all else { return properties.count }
        return properties.filter { $0.status == filter.rawValue }.count
    }

    private let apiClient: APIClient
    private let subscriptionService: SubscriptionService

    init() {
        let client = APIClient(baseURLString: "http://31.220.56.155:5050")
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            client.defaultHeaders["Authorization"] = "Bearer \(token)"
        }
        self.apiClient = client
        self.subscriptionService = SubscriptionService(apiClient: client)
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        guard let userId = currentUserId() else {
            errorMessage = "تعذّر تحديد هوية المستخدم"
            isLoading = false
            return
        }
        async let propsTask: [MyProperty] = fetchProperties(ownerId: userId)
        async let plansTask: [SubscriptionPlan] = (try? subscriptionService.fetchPlans()) ?? []
        async let activeTask: ActiveSubscription? = try? subscriptionService.fetchActiveSubscription(userId: userId)
        let (props, fetchedPlans, active) = await (propsTask, plansTask, activeTask)
        properties = props
        plans = fetchedPlans.filter { $0.isActive }
        activeSubscription = active
        isLoading = false
    }

    func subscribe() async {
        guard let plan = selectedPlan, let userId = currentUserId() else { return }
        isSubscribing = true
        errorMessage = nil
        do {
            if let active = activeSubscription {
                try await subscriptionService.renew(subscriptionId: active.id, planId: plan.id)
                successMessage = "تم تجديد الاشتراك في \"\(plan.name)\" بنجاح"
            } else {
                _ = try await subscriptionService.subscribe(businessOwnerId: userId, planId: plan.id)
                successMessage = "تم الاشتراك في \"\(plan.name)\" بنجاح"
            }
            await load()
        } catch APIError.badRequest(let msg) {
            errorMessage = msg.contains("Insufficient")
                ? "رصيد المحفظة غير كافٍ لإتمام الاشتراك"
                : msg
        } catch {
            errorMessage = "فشل إتمام الاشتراك، يرجى المحاولة مجدداً"
        }
        isSubscribing = false
    }

    // MARK: Private helpers
    private func currentUserId() -> String? {
        guard let token = UserDefaults.standard.string(forKey: "auth_token"),
              let payload = decodeJWTPayload(token),
              let sub = payload["sub"] as? String ?? payload["nameid"] as? String
        else { return nil }
        return sub
    }

    private func fetchProperties(ownerId: String) async -> [MyProperty] {
        struct RawImage: Codable { let url: String; let isMain: Bool? }
        struct RawLocation: Codable { let city: String; let state: String }
        struct RawProperty: Codable {
            let id: String
            let title: String
            let price: Double
            let currency: String
            let isAd: Bool
            let status: String
            let location: RawLocation
            let images: [RawImage]?
        }
        do {
            let raw: [RawProperty] = try await apiClient.get(
                to: "/api/v1/AllProperties/by-owner/\(ownerId)"
            )
            return raw.map {
                let mainImage = $0.images?.first(where: { $0.isMain == true })?.url
                    ?? $0.images?.first?.url
                return MyProperty(
                    id: $0.id,
                    title: $0.title,
                    price: $0.price,
                    currency: $0.currency,
                    isAd: $0.isAd,
                    status: $0.status,
                    location: MyPropertyLocation(city: $0.location.city, state: $0.location.state),
                    mainImageUrl: mainImage
                )
            }
        } catch {
            print("❌ fetchProperties error: \(error)")
            return []
        }
    }

    private func decodeJWTPayload(_ token: String) -> [String: Any]? {
        let parts = token.components(separatedBy: ".")
        guard parts.count == 3 else { return nil }
        var base64 = parts[1]
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let remainder = base64.count % 4
        if remainder > 0 { base64 += String(repeating: "=", count: 4 - remainder) }
        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return nil }
        return json
    }
}

struct NotificationsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = NotificationsViewModel()
    private let brand = Color(red: 136/255, green: 65/255, blue: 122/255)

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                if viewModel.isLoading && viewModel.notifications.isEmpty {
                    ProgressView("جارٍ التحميل...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.notifications.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 56))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("لا توجد إشعارات")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.notifications) { item in
                            NavigationLink(destination: NotificationDetailView(item: item, viewModel: viewModel)) {
                                NotificationRow(item: item, brand: brand)
                            }
                            .listRowBackground(
                                item.isRead ? Color.white : brand.opacity(0.05)
                            )
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    Task { await viewModel.delete(item) }
                                } label: {
                                    Label("حذف", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                if !item.isRead {
                                    Button {
                                        Task { await viewModel.markAsRead(item) }
                                    } label: {
                                        Label("مقروء", systemImage: "envelope.open")
                                    }
                                    .tint(.blue)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .refreshable { await viewModel.fetch() }
                }
            }
            .navigationTitle("الإشعارات")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("إغلاق") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.unreadCount > 0 {
                        Button("قراءة الكل") {
                            Task { await viewModel.markAllAsRead() }
                        }
                        .font(.caption)
                        .foregroundColor(brand)
                    }
                }
            }
            .task {
                await viewModel.fetch()
                viewModel.startAutoRefresh()
            }
            .onDisappear { viewModel.stopAutoRefresh() }
        }
    }
}

// MARK: - Notification row
private struct NotificationRow: View {
    let item: NotificationItem
    let brand: Color

    var body: some View {
        HStack(spacing: 12) {
            // Unread dot
            Circle()
                .fill(item.isRead ? Color.clear : brand)
                .frame(width: 9, height: 9)

            VStack(alignment: .trailing, spacing: 4) {
                Text(item.message)
                    .font(.subheadline)
                    .fontWeight(item.isRead ? .regular : .semibold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(2)

                Text(item.timeAgo)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Notification detail
struct NotificationDetailView: View {
    let item: NotificationItem
    @ObservedObject var viewModel: NotificationsViewModel
    private let brand = Color(red: 136/255, green: 65/255, blue: 122/255)

    var body: some View {
        ScrollView {
            VStack(alignment: .trailing, spacing: 20) {
                // Header
                HStack {
                    Spacer()
                    Image(systemName: "bell.fill")
                        .font(.system(size: 40))
                        .foregroundColor(brand)
                }
                .padding(.top, 8)

                // Message
                Text(item.message)
                    .font(.body)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                Divider()

                // Time
                HStack {
                    Spacer()
                    Label(item.timeAgo, systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Read status
                HStack {
                    Spacer()
                    Label(
                        item.isRead ? "تمت القراءة" : "غير مقروءة",
                        systemImage: item.isRead ? "envelope.open.fill" : "envelope.fill"
                    )
                    .font(.caption)
                    .foregroundColor(item.isRead ? .green : .orange)
                }
            }
            .padding()
        }
        .navigationTitle("تفاصيل الإشعار")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.markAsRead(item) }
    }
}

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    
    var body: some View {
        List {
            Section("الإعدادات العامة") {
                Toggle("الإشعارات", isOn: $notificationsEnabled)
                Toggle("الوضع الليلي", isOn: $darkModeEnabled)
                    .onChange(of: darkModeEnabled) { newValue in
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                            windowScene.windows.first?.overrideUserInterfaceStyle = newValue ? .dark : .light
                        }
                    }
            }
            
            Section("الخصوصية") {
                NavigationLink {
                    PrivacyPolicyView()
                } label: {
                    Text("سياسة الخصوصية")
                }
                NavigationLink {
                    TermsOfServiceView()
                } label: {
                    Text("شروط الاستخدام")
                }
            }
            
            Section("حول التطبيق") {
                HStack {
                    Text("الإصدار")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("الإعدادات")
        .onAppear {
            if darkModeEnabled {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    windowScene.windows.first?.overrideUserInterfaceStyle = .dark
                }
            }
        }
    }
}


struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("سياسة الخصوصية")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                
                PolicySection(
                    title: "جمع المعلومات",
                    content: "نقوم بجمع المعلومات التي تقدمها لنا عند التسجيل في التطبيق، بما في ذلك الاسم والبريد الإلكتروني ورقم الهاتف."
                )
                
                PolicySection(
                    title: "استخدام المعلومات",
                    content: "نستخدم معلوماتك لتوفير وتحسين خدماتنا، والتواصل معك بشأن حسابك وخدماتنا."
                )
                
                PolicySection(
                    title: "حماية المعلومات",
                    content: "نتخذ تدابير أمنية معقولة لحماية معلوماتك الشخصية من الوصول غير المصرح به أو الاستخدام أو الكشف."
                )
                
                PolicySection(
                    title: "مشاركة المعلومات",
                    content: "لا نشارك معلوماتك الشخصية مع أطراف ثالثة إلا بموافقتك أو عند الضرورة لتقديم خدماتنا."
                )
                
                PolicySection(
                    title: "حقوقك",
                    content: "لديك الحق في الوصول إلى معلوماتك الشخصية وتصحيحها أو حذفها. يمكنك الاتصال بنا لممارسة هذه الحقوق."
                )
                
                Text("آخر تحديث: 17 فبراير 2026")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 20)
            }
            .padding()
        }
        .navigationTitle("سياسة الخصوصية")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("شروط الاستخدام")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                
                PolicySection(
                    title: "قبول الشروط",
                    content: "باستخدامك لهذا التطبيق، فإنك توافق على الالتزام بهذه الشروط والأحكام."
                )
                
                PolicySection(
                    title: "استخدام الخدمة",
                    content: "يجب عليك استخدام التطبيق بطريقة قانونية ومسؤولة. يُحظر أي استخدام قد يضر بالتطبيق أو المستخدمين الآخرين."
                )
                
                PolicySection(
                    title: "المحتوى",
                    content: "أنت مسؤول عن المحتوى الذي تنشره على التطبيق. يجب أن يكون المحتوى دقيقاً وقانونياً."
                )
                
                PolicySection(
                    title: "الدفع والاسترداد",
                    content: "جميع المدفوعات نهائية وغير قابلة للاسترداد ما لم ينص على خلاف ذلك. الأسعار قابلة للتغيير دون إشعار مسبق."
                )
                
                PolicySection(
                    title: "إنهاء الحساب",
                    content: "نحتفظ بالحق في تعليق أو إنهاء حسابك في حالة انتهاك هذه الشروط."
                )
                
                PolicySection(
                    title: "تحديد المسؤولية",
                    content: "لا نتحمل المسؤولية عن أي أضرار مباشرة أو غير مباشرة ناتجة عن استخدام التطبيق."
                )
                
                Text("آخر تحديث: 17 فبراير 2026")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 20)
            }
            .padding()
        }
        .navigationTitle("شروط الاستخدام")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PolicySection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(Color(hex: "#88417A"))
            
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
