// Features/Home/Views/AdPackageCard.swift

import SwiftUI

enum AdStatus {
    case active, inactive
}

struct AdPackageCard: View {
    let title: String
    let price: String
    let date: String
    let description: String
    let status: AdStatus
    let adsCount: Int // e.g., 1
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) { // 🔹 Reduced spacing for tighter layout
            // Row 1: price/date + checkmark (top-left + top-right)
            HStack {
                Text("\(price) دينار / \(date)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if status == .active {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                }
            }
            .padding(.horizontal, 16)
            
            // Row 2: Title
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.horizontal, 16)
            
            // Row 3: Description
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .padding(.horizontal, 16)
            
            // Row 4: Status line (only for active)
            if status == .active {
                HStack {
                    Text("يمكنك إضافة إعلان")
                        .font(.caption)
                        .foregroundColor(.primary)
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                }
                .padding(.horizontal, 16)
            }
            
            // Row 5: Ads count
            Text("\(adsCount) : عدد الإعلانات")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)
            
            // Divider
            Divider()
                .padding(.horizontal, 16)
            
            // Button
            Button("اشتراك") {
                // Navigate to payment
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
            .background(Color(red: 136/255, green: 65/255, blue: 122/255)) // #88417A
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 3)
        .frame(height: 265) // ✅ Matches PNG height (~265pt)
        .padding(.horizontal, 16) // Full-width with safe margins
    }
}
