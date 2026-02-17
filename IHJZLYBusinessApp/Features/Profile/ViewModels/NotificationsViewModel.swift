// Features/Profile/ViewModels/NotificationsViewModel.swift
import Foundation
import SwiftUI
import Combine

struct NotificationItem: Identifiable, Codable {
    let id: String
    let title: String
    let message: String
    let details: String?
    let isRead: Bool
    let createdAt: String
    
    var timeAgo: String {
        "منذ ساعتين"
    }
}

@MainActor
class NotificationsViewModel: ObservableObject {
    @Published var notifications: [NotificationItem] = []
    @Published var isLoading = false
    
    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }
    
    func loadNotifications() {
        isLoading = true
        
        Task {
            await Task.sleep(1_000_000_000)
            self.notifications = [
                NotificationItem(id: "1", title: "حجز جديد", message: "تم حجز غرفتك في فندق الريف", details: "الحجز من تاريخ 2026-03-20 إلى 2026-03-25. السعر الإجمالي: 1250 د.ل", isRead: false, createdAt: "2026-02-17T10:00:00Z"),
                NotificationItem(id: "2", title: "تأكيد الدفع", message: "تم استلام الدفعة بنجاح", details: "مبلغ 250 د.ل تم إضافته إلى محفظتك", isRead: false, createdAt: "2026-02-17T09:00:00Z"),
                NotificationItem(id: "3", title: "تقييم جديد", message: "حصلت على تقييم 5 نجوم", details: nil, isRead: true, createdAt: "2026-02-16T15:00:00Z")
            ]
            self.isLoading = false
        }
    }
}
