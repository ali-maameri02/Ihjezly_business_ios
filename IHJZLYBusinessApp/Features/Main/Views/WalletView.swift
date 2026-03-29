// Features/Main/Views/WalletView.swift
import SwiftUI

private let brand = Color.brand

// MARK: - Root view

struct WalletView: View {
    @StateObject private var vm = WalletViewModel()
    @State private var showPaymentSheet = false
    @State private var showWithdrawSheet = false

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
                            BalanceCard(
                                wallet: vm.wallet,
                                onAdd: { showPaymentSheet = true },
                                onWithdraw: { showWithdrawSheet = true }
                            )
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
            .sheet(isPresented: $showWithdrawSheet) {
                WithdrawSheet(vm: vm)
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
    let onWithdraw: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("الرصيد الحالي")
                .font(.subheadline).foregroundColor(.secondary)

            Text(wallet?.formattedBalance ?? "---")
                .font(.system(size: 44, weight: .bold))
                .foregroundColor(brand)

            HStack(spacing: 12) {
                Button(action: onWithdraw) {
                    Label("سحب", systemImage: "arrow.up.circle.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.red.opacity(0.85))
                        .cornerRadius(12)
                }
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
        }
        .padding(20)
        .background(Color.cardBackground)
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
        .background(Color.cardBackground)
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
            .background(Color.cardBackground)
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

// MARK: - Withdraw sheet

private struct WithdrawSheet: View {
    @ObservedObject var vm: WalletViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var amount = ""
    @State private var accountHolderName = ""
    @State private var bankName = ""
    @State private var accountNumber = ""
    @State private var descriptionText = ""
    @State private var showConfirm = false
    @State private var showHistory = false

    private var amountDouble: Double { Double(amount) ?? 0 }
    private var balance: Double { vm.wallet?.amount ?? 0 }

    private var insufficientBalance: Bool { amountDouble > 0 && amountDouble > balance }
    private var formValid: Bool {
        amountDouble > 0 && !accountHolderName.isEmpty &&
        !bankName.isEmpty && !accountNumber.isEmpty && !insufficientBalance
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Balance indicator
                    HStack {
                        Text("الرصيد المتاح")
                            .font(.subheadline).foregroundColor(.secondary)
                        Spacer()
                        Text(vm.wallet?.formattedBalance ?? "---")
                            .font(.subheadline).fontWeight(.bold)
                            .foregroundColor(brand)
                    }
                    .padding(14)
                    .background(brand.opacity(0.07))
                    .cornerRadius(10)

                    // Amount field with inline balance warning
                    VStack(alignment: .leading, spacing: 6) {
                        Text("المبلغ (د.ل)").font(.caption).foregroundColor(.secondary)
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(insufficientBalance ? Color.red : Color.clear, lineWidth: 1.5)
                            )
                        if insufficientBalance {
                            Text("الرصيد غير كافٍ")
                                .font(.caption).foregroundColor(.red)
                        }
                    }

                    FormField(label: "اسم صاحب الحساب",   placeholder: "الاسم الكامل",        text: $accountHolderName)
                    FormField(label: "اسم البنك",          placeholder: "مثال: مصرف الجمهورية", text: $bankName)
                    FormField(label: "رقم الحساب / IBAN",  placeholder: "رقم الحساب البنكي",   text: $accountNumber)
                    FormField(label: "ملاحظة (اختياري)",   placeholder: "سبب السحب",           text: $descriptionText)

                    // Submit button
                    Button {
                        showConfirm = true
                    } label: {
                        Group {
                            if vm.withdrawIsLoading {
                                ProgressView().tint(.white)
                            } else {
                                Label("تقديم طلب السحب", systemImage: "arrow.up.circle.fill")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .foregroundColor(.white)
                        .background(formValid ? Color.red.opacity(0.85) : Color.gray.opacity(0.4))
                        .cornerRadius(12)
                    }
                    .disabled(!formValid || vm.withdrawIsLoading)

                    // History toggle
                    Button {
                        showHistory.toggle()
                        if showHistory { Task { await vm.fetchWithdrawHistory() } }
                    } label: {
                        Label(showHistory ? "إخفاء سجل السحوبات" : "عرض سجل السحوبات",
                              systemImage: showHistory ? "chevron.up" : "clock.arrow.circlepath")
                            .font(.subheadline)
                            .foregroundColor(brand)
                    }

                    if showHistory {
                        WithdrawHistoryList(
                            withdrawals: vm.withdrawHistory,
                            isLoading: vm.withdrawHistoryLoading
                        )
                    }
                }
                .padding(20)
            }
            .navigationTitle("سحب الرصيد")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("إغلاق") { dismiss() }
                }
            }
            .confirmationDialog(
                "تأكيد طلب السحب",
                isPresented: $showConfirm,
                titleVisibility: .visible
            ) {
                Button("تأكيد السحب", role: .destructive) {
                    Task {
                        await vm.createWithdraw(
                            amount: amountDouble,
                            accountHolderName: accountHolderName,
                            bankName: bankName,
                            accountNumber: accountNumber,
                            description: descriptionText.isEmpty ? nil : descriptionText
                        )
                        if vm.successMessage != nil { dismiss() }
                    }
                }
                Button("إلغاء", role: .cancel) {}
            } message: {
                Text("سيتم خصم \(String(format: "%.2f", amountDouble)) د.ل من رصيدك وإرسال الطلب للمراجعة.")
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .presentationDetents([.large])
    }
}

// MARK: - Withdraw history list

private struct WithdrawHistoryList: View {
    let withdrawals: [WithdrawDto]
    let isLoading: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("سجل طلبات السحب")
                .font(.headline)

            if isLoading {
                ProgressView().frame(maxWidth: .infinity)
            } else if withdrawals.isEmpty {
                Text("لا توجد طلبات سحب سابقة")
                    .font(.subheadline).foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                ForEach(withdrawals) { w in
                    WithdrawHistoryRow(withdraw: w)
                }
            }
        }
    }
}

private struct WithdrawHistoryRow: View {
    let withdraw: WithdrawDto
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(withdraw.statusColor.opacity(0.15))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: withdraw.status == 1 ? "checkmark" : withdraw.status == 2 ? "xmark" : "clock")
                        .font(.caption).fontWeight(.bold)
                        .foregroundColor(withdraw.statusColor)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(withdraw.bankName)
                    .font(.subheadline).fontWeight(.medium)
                Text(withdraw.formattedDate)
                    .font(.caption).foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(withdraw.formattedAmount)
                    .font(.subheadline).fontWeight(.bold)
                    .foregroundColor(.red)
                Text(withdraw.statusLabel)
                    .font(.caption2).fontWeight(.semibold)
                    .foregroundColor(withdraw.statusColor)
                    .padding(.horizontal, 7).padding(.vertical, 2)
                    .background(withdraw.statusColor.opacity(0.12))
                    .cornerRadius(8)
            }
        }
        .padding(12)
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 1)
    }
}
