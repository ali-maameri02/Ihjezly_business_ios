// Features/Home/Views/AppBarView.swift

import SwiftUI

struct AppBarView: View {
    @StateObject private var viewModel = UserProfileViewModel()
    
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
            
        
            
            ZStack {
                Image(systemName: "bell.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
                if viewModel.currentUser != nil {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 16, height: 16)
                        .offset(x: 8, y: -8)
                    Text("1")
                        .font(.caption2)
                        .foregroundColor(.white)
                        .offset(x: 8, y: -8)
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 80)
        .background(Color.white)
//        .shadow(radius: 2)
        .environment(\.layoutDirection, .rightToLeft)
    }
}
