// Features/Main/Views/BookingsView.swift
import SwiftUI

struct BookingsView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("", selection: $selectedTab) {
                    Text("القادمة").tag(0)
                    Text("السابقة").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                if selectedTab == 0 {
                    UpcomingBookingsView()
                } else {
                    PastBookingsView()
                }
            }
            .navigationTitle("الحجوزات")
        }
    }
}

struct UpcomingBookingsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(0..<3) { _ in
                    BookingCard(
                        propertyName: "فندق الريف",
                        date: "2026-03-20",
                        status: "مؤكد",
                        price: "250 د.ل"
                    )
                }
            }
            .padding()
        }
    }
}

struct PastBookingsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(0..<2) { _ in
                    BookingCard(
                        propertyName: "شاليه البحر",
                        date: "2026-02-15",
                        status: "مكتمل",
                        price: "180 د.ل"
                    )
                }
            }
            .padding()
        }
    }
}

struct BookingCard: View {
    let propertyName: String
    let date: String
    let status: String
    let price: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(propertyName)
                    .font(.headline)
                Spacer()
                Text(status)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.2))
                    .foregroundColor(.green)
                    .cornerRadius(8)
            }
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.secondary)
                Text(date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text(price)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#88417A"))
                Spacer()
                Button("التفاصيل") {}
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "#88417A"))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
