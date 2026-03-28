// Features/Subscription/ViewModels/SubscriptionViewModel.swift
import Foundation
import Combine

@MainActor
final class SubscriptionViewModel: ObservableObject {
    @Published var plans: [SubscriptionPlan] = []
    @Published var activeSubscription: ActiveSubscription? = nil
    @Published var selectedPlan: SubscriptionPlan? = nil
    @Published var isLoading = false
    @Published var isSubscribing = false
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil
    @Published var showConfirmSheet = false

    private let service: SubscriptionService
    private let userId: String

    init(userId: String) {
        self.userId = userId
        let client = APIClient(baseURLString: "http://31.220.56.155:5050")
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            client.defaultHeaders["Authorization"] = "Bearer \(token)"
        }
        self.service = SubscriptionService(apiClient: client)
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        async let plansTask = service.fetchPlans()
        async let activeTask = service.fetchActiveSubscription(userId: userId)
        do {
            let (fetchedPlans, active) = try await (plansTask, activeTask)
            plans = fetchedPlans.filter { $0.isActive }
            activeSubscription = active
        } catch {
            errorMessage = "فشل تحميل خطط الاشتراك"
        }
        isLoading = false
    }

    func confirmSubscribe(to plan: SubscriptionPlan) {
        selectedPlan = plan
        showConfirmSheet = true
    }

    func subscribe() async {
        guard let plan = selectedPlan else { return }
        isSubscribing = true
        errorMessage = nil
        showConfirmSheet = false
        do {
            if let active = activeSubscription {
                try await service.renew(subscriptionId: active.id, planId: plan.id)
                successMessage = "تم تجديد الاشتراك في \"\(plan.name)\" بنجاح"
            } else {
                _ = try await service.subscribe(businessOwnerId: userId, planId: plan.id)
                successMessage = "تم الاشتراك في \"\(plan.name)\" بنجاح"
            }
            await load()
        } catch APIError.badRequest(let msg) {
            if msg.contains("InsufficientBalance") || msg.contains("Insufficient") {
                errorMessage = "رصيد المحفظة غير كافٍ لإتمام الاشتراك"
            } else {
                errorMessage = msg
            }
        } catch {
            errorMessage = "فشل إتمام الاشتراك، يرجى المحاولة مجدداً"
        }
        isSubscribing = false
    }
}
