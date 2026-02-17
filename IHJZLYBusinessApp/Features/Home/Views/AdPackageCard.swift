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
    let adsCount: Int
    @State private var showSubscription = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
            
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.horizontal, 16)
            
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .padding(.horizontal, 16)
            
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
            
            Text("\(adsCount) : عدد الإعلانات")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)
            
            Divider()
                .padding(.horizontal, 16)
            
            Button("اشتراك") {
                showSubscription = true
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
            .background(Color(red: 136/255, green: 65/255, blue: 122/255))
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 3)
        .frame(height: 265)
        .padding(.horizontal, 16)
        .sheet(isPresented: $showSubscription) {
            AdSubscriptionView(packageTitle: title, price: price)
        }
    }
}

struct AdSubscriptionView: View {
    let packageTitle: String
    let price: String
    @Environment(\.dismiss) var dismiss
    @State private var isProcessing = false
    @State private var showSuccess = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "megaphone.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(hex: "#88417A"))
                    .padding(.top, 40)
                
                Text("باقة \(packageTitle)")
                    .font(.title)
                    .fontWeight(.bold)
                
                VStack(spacing: 16) {
                    HStack {
                        Text("السعر:")
                            .font(.headline)
                        Spacer()
                        Text("\(price) دينار")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "#88417A"))
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        FeatureRow(text: "إضافة إعلان واحد")
                        FeatureRow(text: "ظهور في الصفحة الرئيسية")
                        FeatureRow(text: "مدة 7 أيام")
                        FeatureRow(text: "دعم فني 24/7")
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 2)
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: { processSubscription() }) {
                    if isProcessing {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("تأكيد الاشتراك")
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "#88417A"))
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)
                .disabled(isProcessing)
            }
            .navigationTitle("اشتراك في باقة")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("إغلاق") { dismiss() }
                }
            }
            .alert("نجاح", isPresented: $showSuccess) {
                Button("حسناً") { dismiss() }
            } message: {
                Text("تم الاشتراك بنجاح")
            }
        }
    }
    
    func processSubscription() {
        isProcessing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isProcessing = false
            showSuccess = true
        }
    }
}

struct FeatureRow: View {
    let text: String
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            Text(text)
                .font(.subheadline)
            Spacer()
        }
    }
}
