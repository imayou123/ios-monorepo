//
//  PaymentConfirmationViewModel.swift
//  GinBankSDKExampleBank
//
//  Created by David Vizaknai on 01.04.2022.
//

import SwiftUI
import GiniBankSDK
import GiniBankAPILibrary

public class PaymentConfirmationViewModel: ObservableObject {
    private var bankSDK: GiniBank
    private var paymentRequest: ResolvedPaymentRequest
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate

    var dismiss: (() -> Void)?

    @Published var date: Date = Date()
    @Published var price: String = ""
    @Published var id: String = ""
    @Published var invoiceTitle: String = ""

    init(with giniApiLib: GiniBankAPI, paymentRequest: ResolvedPaymentRequest) {
        bankSDK = GiniBank(with: giniApiLib)
        self.paymentRequest = paymentRequest
    }

    func openPaymentRequesterApp() {
        dismiss?()
        bankSDK.returnBackToBusinessAppHandler(resolvedPaymentRequest: paymentRequest)
    }


    func fetchPayment(){
        bankSDK.paymentService.payment(id: appDelegate.paymentRequestId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(payment):
                DispatchQueue.main.async {
                    self.invoiceTitle = payment.recipient
                    self.id = "#390913832472"
                    self.date = Date()
                    if let priceString = payment.amount.split(separator: ":").first, let priceDouble = Double(priceString) {
                        self.price = "\(String(format: "%.2f", priceDouble))"
                    } else {
                        self.price = "99.00"
                    }
                }
            case .failure:
                print("error")
            }
        }
    }
}
