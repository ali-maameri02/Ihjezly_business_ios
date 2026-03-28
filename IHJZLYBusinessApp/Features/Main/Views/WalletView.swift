// Features/Main/Views/WalletView.swift
import SwiftUI

private let brand = Color(red: 136/255, green: 65/255, blue: 122/255)

// MARK: - Root view

struct WalletView: View {
    @StateObject private var vm = WalletViewModel()
    @State private var showPaymentSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                if vm.isLoading {
                    ProgressView("جارٍ التحميل...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            BalanceCard(wallet: vm.wallet) {
                                showPaymentSheet = true
                            }
                            TransactionsList(transactions: vm.transactions)
                        }
                        .padding(.vertical, 16)
                    }
                    .refreshable { await vm.fetchAll() }
                }
            }
            .navigationTitle("المحفظة")
            .navigationBarTitleDisplayMode(.inline)
            .task { await vm.fetchAll() }
            .sheet(isPresented: $showPaymentSheet) {
                PaymentMethodSheet(vm: vm)
            }
            .alert("خطأ", isPresented: .init(
                get: { vm.errorMessage != nil },
                set: { if !$0 { vm.errorMessage = nil } }
            )) {
                Button("حسناً") { vm.errorMessage = nil }
            } message: { Text(vm.errorMessage ?? "") }
            .alert("تم بنجاح ✓", isPresented: .init(
                get: { vm.successMessage != nil },
                set: { if !$0 { vm.successMessage = nil } }
            )) {
                Button("حسناً") { vm.successMessage = nil }
            } message: { Text(vm.successMessage ?? "") }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}

// MARK: - Balance card

private struct BalanceCard: View {
    let wallet: WalletDto?
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("الرصيد الحالي")
                .font(.subheadline).foregroundColor(.secondary)

            Text(wallet?.formattedBalance ?? "---")
                .font(.system(size: 44, weight: .bold))
                .foregroundColor(brand)

            Button(action: onAdd) {
                Label("إضافة رصيد", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(brand)
                    .cornerRadius(12)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.07), radius: 6, x: 0, y: 2)
        .padding(.horizontal, 16)
    }
}

// MARK: - Transactions list

private struct TransactionsList: View {
    let transactions: [TransactionDto]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("سجل المعاملات")
                .font(.headline)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)

            if transactions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 44))
                        .foregroundColor(.gray.opacity(0.4))
                    Text("لا توجد معاملات بعد")
                        .font(.subheadline).foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 8) {
                    ForEach(transactions) { tx in
                        TransactionRow(tx: tx)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

private struct TransactionRow: View {
    let tx: TransactionDto
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: tx.isCredit ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                .font(.title2)
                .foregroundColor(tx.isCredit ? .green : .red)

            VStack(alignment: .leading, spacing: 3) {
                Text(tx.description)
                    .font(.subheadline).fontWeight(.medium)
                    .lineLimit(1)
                Text(tx.formattedDate)
                    .font(.caption).foregroundColor(.secondary)
            }

            Spacer()

            Text(tx.formattedAmount)
                .font(.subheadline).fontWeight(.bold)
                .foregroundColor(tx.isCredit ? .green : .red)
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 1)
    }
}

// MARK: - Payment method selection sheet

private struct PaymentMethodSheet: View {
    @ObservedObject var vm: WalletViewModel
    @Environment(\.dismiss) private var dismiss

    enum Method { case sadad, edfali, prepaid }
    @State private var selected: Method?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let method = selected {
                    // Navigate into the chosen method form
                    switch method {
                    case .sadad:   SadadForm(vm: vm, onDone: { dismiss() })
                    case .edfali:  EdfaliForm(vm: vm, onDone: { dismiss() })
                    case .prepaid: PrepaidForm(vm: vm, onDone: { dismiss() })
                    }
                } else {
                    methodList
                }
            }
            .navigationTitle("اختر طريقة الدفع")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("إغلاق") { dismiss() }
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .presentationDetents([.medium, .large])
    }

    private var methodList: some View {
        VStack(spacing: 12) {
            MethodCard(
                icon: "creditcard.fill",
                title: "سداد",
                subtitle: "ادفع عبر خدمة سداد مع رمز OTP",
                color: .blue
            ) { selected = .sadad }

            MethodCard(
                icon: "iphone.radiowaves.left.and.right",
                title: "إدفعلي",
                subtitle: "ادفع عبر إدفعلي مع رمز تأكيد",
                color: .green
            ) { selected = .edfali }

            MethodCard(
                icon: "rectangle.and.pencil.and.ellipsis",
                title: "بطاقة شحن",
                subtitle: "أدخل رقم بطاقة الشحن المسبق",
                color: brand
            ) { selected = .prepaid }
        }
        .padding(20)
    }
}

private struct MethodCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(color)
                    .cornerRadius(12)

                VStack(alignment: .leading, spacing: 3) {
                    Text(title).font(.headline)
                    Text(subtitle).font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.left")
                    .font(.caption).foregroundColor(.secondary)
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Sadad form (initiate → OTP → confirm)

private struct SadadForm: View {
    @ObservedObject var vm: WalletViewModel
    let onDone: () -> Void

    @State private var msisdn = ""
    @State private var birthYear = ""
    @State private var amount = ""
    @State private var otp = ""

    private var awaitingOtp: Bool { vm.sadadSessionId != nil }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if !awaitingOtp {
                    FormHeader(icon: "creditcard.fill", color: .blue, title: "سداد")

                    FormField(label: "رقم الهاتف (Msisdn)", placeholder: "218XXXXXXXXX", text: $msisdn)
                        .keyboardType(.phonePad)
                    FormField(label: "سنة الميلاد", placeholder: "مثال: 1990", text: $birthYear)
                        .keyboardType(.numberPad)
                    FormField(label: "المبلغ (د.ل)", placeholder: "0.00", text: $amount)
                        .keyboardType(.decimalPad)

                    ActionButton(
                        title: "إرسال طلب الدفع",
                        isLoading: vm.sadadIsLoading,
                        disabled: msisdn.isEmpty || birthYear.isEmpty || amount.isEmpty
                    ) {
                        Task { await vm.sadadInitiate(
                            msisdn: msisdn,
                            birthYear: birthYear,
                            amount: Double(amount) ?? 0
                        )}
                    }
                } else {
                    FormHeader(icon: "lock.shield.fill", color: .blue, title: "رمز التحقق - سداد")

                    Text("أدخل رمز OTP المرسل إلى هاتفك")
                        .font(.subheadline).foregroundColor(.secondary)

                    OTPField(otp: $otp)

                    ActionButton(
                        title: "تأكيد الدفع",
                        isLoading: vm.sadadIsLoading,
                        disabled: otp.count < 4
                    ) {
                        Task {
                            await vm.sadadConfirm(otp: otp)
                            if vm.successMessage != nil { onDone() }
                        }
                    }

                    Button("إعادة إرسال الرمز") {
                        Task { await vm.sadadResendOtp() }
                    }
                    .font(.subheadline).foregroundColor(brand)
                }
            }
            .padding(20)
        }
    }
}

// MARK: - Edfali form (initiate → OTP → confirm)

private struct EdfaliForm: View {
    @ObservedObject var vm: WalletViewModel
    let onDone: () -> Void

    @State private var mobile = ""
    @State private var amount = ""
    @State private var pin = ""

    private var awaitingPin: Bool { vm.edfaliSessionId != nil }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if !awaitingPin {
                    FormHeader(icon: "iphone.radiowaves.left.and.right", color: .green, title: "إدفعلي")

                    FormField(label: "رقم الهاتف", placeholder: "218XXXXXXXXX", text: $mobile)
                        .keyboardType(.phonePad)
                    FormField(label: "المبلغ (د.ل)", placeholder: "0.00", text: $amount)
                        .keyboardType(.decimalPad)

                    ActionButton(
                        title: "إرسال طلب الدفع",
                        isLoading: vm.edfaliIsLoading,
                        disabled: mobile.isEmpty || amount.isEmpty
                    ) {
                        Task { await vm.edfaliInitiate(
                            mobile: mobile,
                            amount: Double(amount) ?? 0
                        )}
                    }
                } else {
                    FormHeader(icon: "lock.shield.fill", color: .green, title: "رمز التأكيد - إدفعلي")

                    Text("أدخل رمز التأكيد المرسل إلى هاتفك")
                        .font(.subheadline).foregroundColor(.secondary)

                    OTPField(otp: $pin)

                    ActionButton(
                        title: "تأكيد الدفع",
                        isLoading: vm.edfaliIsLoading,
                        disabled: pin.count < 4
                    ) {
                        Task {
                            await vm.edfaliConfirm(pin: pin)
                            if vm.successMessage != nil { onDone() }
                        }
                    }
                }
            }
            .padding(20)
        }
    }
}

// MARK: - Prepaid card form

private struct PrepaidForm: View {
    @ObservedObject var vm: WalletViewModel
    let onDone: () -> Void

    @State private var cardNumber = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                FormHeader(icon: "rectangle.and.pencil.and.ellipsis", color: brand, title: "بطاقة شحن")

                FormField(label: "رقم البطاقة", placeholder: "أدخل رقم بطاقة الشحن", text: $cardNumber)
                    .keyboardType(.numberPad)

                ActionButton(
                    title: "تفعيل البطاقة",
                    isLoading: vm.prepaidIsLoading,
                    disabled: cardNumber.isEmpty
                ) {
                    Task {
                        await vm.usePrepaidCard(cardNumber: cardNumber)
                        if vm.successMessage != nil { onDone() }
                    }
                }
            }
            .padding(20)
        }
    }
}

// MARK: - Shared sub-components

private struct FormHeader: View {
    let icon: String; let color: Color; let title: String
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 36))
                .foregroundColor(color)
            Text(title).font(.title3).fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 4)
    }
}

private struct FormField: View {
    let label: String; let placeholder: String
    @Binding var text: String
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.caption).foregroundColor(.secondary)
            TextField(placeholder, text: $text)
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(10)
        }
    }
}

private struct OTPField: View {
    @Binding var otp: String
    var body: some View {
        TextField("رمز التحقق", text: $otp)
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .font(.title2).fontWeight(.bold)
            .tracking(8)
            .padding(14)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .onChange(of: otp) { _, new in
                otp = String(new.filter(\.isNumber).prefix(6))
            }
    }
}

private struct ActionButton: View {
    let title: String
    let isLoading: Bool
    let disabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text(title).fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundColor(.white)
            .background(disabled || isLoading ? Color.gray.opacity(0.4) : brand)
            .cornerRadius(12)
        }
        .disabled(disabled || isLoading)
    }
}
