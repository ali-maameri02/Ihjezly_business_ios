// Features/Home/Views/AppBarView.swift

import SwiftUI

struct AppBarView: View {
    @StateObject private var viewModel = UserProfileViewModel()
    @StateObject private var notificationsVM = NotificationsViewModel()
    @State private var showNotifications = false

    var body: some View {
        HStack {
            HStack(spacing: 12) {
                Image("ihjzlyapplogo")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.brand.opacity(0.3), lineWidth: 1))

                if let user = viewModel.currentUser {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("مرحباً بك")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(user.displayName)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                }
            }

            Spacer()

            Button {
                showNotifications = true
                notificationsVM.loadNotifications()
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell.fill")
                        .font(.title2)
                        .foregroundColor(.brand)
                        .frame(width: 40, height: 40)
                        .background(Color.brand.opacity(0.1))
                        .clipShape(Circle())

                    if notificationsVM.unreadCount > 0 {
                        Text("\(min(notificationsVM.unreadCount, 99))")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .clipShape(Capsule())
                            .offset(x: 4, y: -4)
                    }
                }
            }
            .sheet(isPresented: $showNotifications) { NotificationsView() }
        }
        .padding(.horizontal, 16)
        .frame(height: 64)
        .background(Color.cardBackground)
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
        .environment(\.layoutDirection, .rightToLeft)
        .onAppear { notificationsVM.loadNotifications() }
    }
}
