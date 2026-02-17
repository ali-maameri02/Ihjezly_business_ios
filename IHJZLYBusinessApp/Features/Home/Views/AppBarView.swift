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
                
                if let user = viewModel.currentUser {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("مرحباً بك")
                            .font(.headline)
                            .fontWeight(.medium)
                        Text("\(user.displayRole) - \(user.displayName)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            Spacer()
            
            Button(action: { 
                showNotifications = true
                notificationsVM.loadNotifications()
            }) {
                ZStack {
                    Image(systemName: "bell.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                    if notificationsVM.unreadCount > 0 {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 16, height: 16)
                            .offset(x: 8, y: -8)
                        Text("\(notificationsVM.unreadCount)")
                            .font(.caption2)
                            .foregroundColor(.white)
                            .offset(x: 8, y: -8)
                    }
                }
            }
            .sheet(isPresented: $showNotifications) {
                NotificationsView()
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 80)
        .background(Color.white)
        .environment(\.layoutDirection, .rightToLeft)
        .onAppear {
            notificationsVM.loadNotifications()
        }
    }
}
