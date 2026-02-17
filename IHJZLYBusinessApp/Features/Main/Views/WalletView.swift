// Features/Main/Views/WalletView.swift
import SwiftUI

struct WalletView: View {
    @State private var balance: Double = 1250.50
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 16) {
                        Text("الرصيد الحالي")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("\(balance, specifier: "%.2f") د.ل")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(Color(hex: "#88417A"))
                        
                        HStack(spacing: 16) {
                            Button(action: {}) {
                                Label("سحب", systemImage: "arrow.down.circle.fill")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(hex: "#88417A"))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            
                            Button(action: {}) {
                                Label("إضافة", systemImage: "arrow.up.circle.fill")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(radius: 4)
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("المعاملات الأخيرة")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(0..<5) { index in
                            TransactionRow(
                                title: index % 2 == 0 ? "حجز فندق الريف" : "سحب رصيد",
                                amount: index % 2 == 0 ? "+250.00" : "-150.00",
                                date: "2026-02-\(20 - index)",
                                isPositive: index % 2 == 0
                            )
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("المحفظة")
        }
    }
}

struct TransactionRow: View {
    let title: String
    let amount: String
    let date: String
    let isPositive: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isPositive ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                .foregroundColor(isPositive ? .green : .red)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                Text(date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(amount) د.ل")
                .font(.headline)
                .foregroundColor(isPositive ? .green : .red)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}
