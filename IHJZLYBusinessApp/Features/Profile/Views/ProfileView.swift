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
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("جارٍ التحميل...")
            } else if viewModel.properties.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "building.2")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("لا توجد عقارات")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            } else {
                List(viewModel.properties) { property in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(property.title)
                            .font(.headline)
                        Text(property.location.city)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        HStack {
                            Text("\(property.price, specifier: "%.0f") د.ل")
                                .font(.subheadline)
                                .foregroundColor(Color(hex: "#88417A"))
                            Spacer()
                            Text("نشط")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green.opacity(0.2))
                                .foregroundColor(.green)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("عقاراتي")
        .onAppear {
            viewModel.loadProperties()
        }
    }
}

@MainActor
class MyPropertiesViewModel: ObservableObject {
    @Published var properties: [PropertyResponse] = []
    @Published var isLoading = false
    
    func loadProperties() {
        isLoading = true
        
        Task {
            do {
                let useCase = GetAllPropertiesUseCase()
                let allProperties = try await useCase.execute()
                self.properties = allProperties.map { prop in
                    PropertyResponse(
                        id: prop.id,
                        title: prop.title,
                        price: prop.price ?? 0,
                        location: PropertyLocation(city: "طرابلس", state: "ليبيا")
                    )
                }
                self.isLoading = false
            } catch {
                self.isLoading = false
            }
        }
    }
}

struct PropertyResponse: Identifiable, Codable {
    let id: String
    let title: String
    let price: Double
    let location: PropertyLocation
}

struct PropertyLocation: Codable {
    let city: String
    let state: String
}

struct NotificationsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = NotificationsViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("جارٍ التحميل...")
                } else if viewModel.notifications.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("لا توجد إشعارات")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                } else {
                    List(viewModel.notifications) { notification in
                        NavigationLink(destination: NotificationDetailView(notification: notification)) {
                            HStack(spacing: 12) {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(Color(hex: "#88417A"))
                                    .frame(width: 30)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(notification.title)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text(notification.message)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                    Text(notification.timeAgo)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                if !notification.isRead {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 8, height: 8)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("الإشعارات")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("إغلاق") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                viewModel.loadNotifications()
            }
        }
    }
}

struct NotificationDetailView: View {
    let notification: NotificationItem
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image(systemName: "bell.fill")
                        .font(.title)
                        .foregroundColor(Color(hex: "#88417A"))
                    Spacer()
                    Text(notification.timeAgo)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(notification.title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(notification.message)
                    .font(.body)
                    .foregroundColor(.secondary)
                
                if let details = notification.details {
                    Divider()
                    Text(details)
                        .font(.body)
                }
            }
            .padding()
        }
        .navigationTitle("تفاصيل الإشعار")
        .navigationBarTitleDisplayMode(.inline)
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
