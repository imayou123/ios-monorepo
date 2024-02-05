//
//  InvoicesListViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniHealthAPILibrary
import GiniCaptureSDK
import GiniBankAPILibrary
import GiniHealthSDK

struct DocumentWithExtractions: GiniDocument, Codable {
    var documentID: String
    var amountToPay: String?
    var paymentDueDate: String?
    var recipient: String?
    var isPayable: Bool?
    var paymentProvider: PaymentProvider?

    init(documentID: String, extractionResult: GiniHealthAPILibrary.ExtractionResult, paymentProvider: PaymentProvider?) {
        self.documentID = documentID
        self.amountToPay = extractionResult.payment?.first?.first(where: {$0.name == "amount_to_pay"})?.value
        self.paymentDueDate = extractionResult.extractions.first(where: {$0.name == "payment_due_date"})?.value
        self.recipient = extractionResult.payment?.first?.first(where: {$0.name == "payment_recipient"})?.value
        self.paymentProvider = paymentProvider
    }
    
    init(documentID: String, extractions: [GiniBankAPILibrary.Extraction], paymentProvider: PaymentProvider?) {
        self.documentID = documentID
        self.amountToPay = extractions.first(where: {$0.name == "amount_to_pay"})?.value
        self.paymentDueDate = extractions.first(where: {$0.name == "payment_due_date"})?.value
        self.recipient = extractions.first(where: {$0.name == "payment_recipient"})?.value
        self.paymentProvider = paymentProvider
    }
}

final class InvoicesListViewModel {
    
    private let coordinator: InvoicesListCoordinator
    private var documentService: GiniHealthAPILibrary.DefaultDocumentService

    private let hardcodedInvoicesController: HardcodedInvoicesControllerProtocol
    var paymentComponentsController: PaymentComponentsController

    var invoices: [DocumentWithExtractions]

    let noInvoicesText = NSLocalizedString("giniHealthSDKExample.invoicesList.missingInvoices.text", comment: "")
    let titleText = NSLocalizedString("giniHealthSDKExample.invoicesList.title", comment: "")
    let uploadInvoicesText = NSLocalizedString("giniHealthSDKExample.uploadInvoices.button.title", comment: "")
    let errorUploadingTitleText = NSLocalizedString("giniHealthSDKExample.invoicesList.erorrUploading", comment: "")
    
    let backgroundColor: UIColor = GiniColor(light: .white, 
                                             dark: .black).uiColor()
    let tableViewSeparatorColor: UIColor = GiniColor(light: .lightGray, 
                                                     dark: .darkGray).uiColor()
    
    private let tableViewCell: UITableViewCell.Type = InvoiceTableViewCell.self
    private var errors: [String] = []

    let dispatchGroup = DispatchGroup()

    init(coordinator: InvoicesListCoordinator,
         invoices: [DocumentWithExtractions]? = nil,
         documentService: GiniHealthAPILibrary.DefaultDocumentService,
         hardcodedInvoicesController: HardcodedInvoicesControllerProtocol,
         paymentComponentsController: PaymentComponentsController) {
        self.coordinator = coordinator
        self.hardcodedInvoicesController = hardcodedInvoicesController
        self.invoices = invoices ?? hardcodedInvoicesController.getInvoicesWithExtractions()
        self.documentService = documentService
        self.paymentComponentsController = paymentComponentsController
    }

    func viewDidLoad() {
        loadPaymentProvidersIfMissingOnInvoices()
    }

    func loadPaymentProvidersIfMissingOnInvoices() {
        if !invoices.isEmpty && invoices.contains(where: { $0.paymentProvider == nil }) {
            coordinator.invoicesListViewController.showActivityIndicator()
            loadPaymentProviders()
            setDispatchGroupNotifier()
        }
    }

    private func setDispatchGroupNotifier() {
        dispatchGroup.notify(queue: .main) {
            if !self.errors.isEmpty {
                let uniqueErrorMessages = Array(Set(self.errors))
                self.coordinator.invoicesListViewController.showErrorAlertView(error: uniqueErrorMessages.joined(separator: ", "))
                self.errors = []
            }
            if !self.invoices.isEmpty {
                self.hardcodedInvoicesController.storeInvoicesWithExtractions(invoices: self.invoices)
                self.coordinator.invoicesListViewController?.hideActivityIndicator()
                self.coordinator.invoicesListViewController?.reloadTableView()
            }
        }
    }

    @objc
    func uploadInvoices() {
        coordinator.invoicesListViewController?.showActivityIndicator()
        hardcodedInvoicesController.obtainInvoicePhotosHardcoded { [weak self] invoicesData in
            if !invoicesData.isEmpty {
                self?.uploadDocuments(dataDocuments: invoicesData)
            } else {
                self?.coordinator.invoicesListViewController.hideActivityIndicator()
            }
        }
        loadPaymentProviders()
        setDispatchGroupNotifier()
    }

    private func loadPaymentProviders() {
        dispatchGroup.enter()
        paymentComponentsController.getPaymentProviders { [weak self] result in
            switch result {
            case .success(_):
                for index in 0..<(self?.invoices.count ?? 0) {
                    self?.invoices[index].paymentProvider = self?.paymentComponentsController.obtainFirstPaymentProvider()
                }
            case let .failure(error):
                self?.errors.append(error.localizedDescription)
            }
            self?.dispatchGroup.leave()
        }
    }

    private func uploadDocuments(dataDocuments: [Data]) {
        for giniDocument in dataDocuments {
            dispatchGroup.enter()
            self.documentService.createDocument(fileName: nil,
                                                docType: .invoice,
                                                type: .partial(giniDocument),
                                                metadata: nil) { [weak self] result in
                switch result {
                case .success(let createdDocument):
                    Log("Successfully created document with id: \(createdDocument.id)", event: .success)
                    self?.documentService.extractions(for: createdDocument,
                                                      cancellationToken: CancellationToken()) { [weak self] result in
                        switch result {
                        case let .success(extractionResult):
                            Log("Successfully fetched extractions for id: \(createdDocument.id)", event: .success)
                            let firstPaymentProvider = self?.paymentComponentsController.obtainFirstPaymentProvider()
                            self?.invoices.append(DocumentWithExtractions(documentID: createdDocument.id,
                                                                          extractionResult: extractionResult, 
                                                                          paymentProvider: firstPaymentProvider))
                            self?.paymentComponentsController.checkIfDocumentIsPayable(docId: createdDocument.id, completion: { [weak self] result in
                                switch result {
                                case let .success(isPayable):
                                    Log("Successfully checked if document \(createdDocument.id) is payable", event: .success)
                                    if let indexDocument = self?.invoices.firstIndex(where: { $0.documentID == createdDocument.id }) {
                                        self?.invoices[indexDocument].isPayable = isPayable
                                    }
                                case let .failure(error):
                                    Log("Checking if document \(createdDocument.id) is payable failed with error: \(String(describing: error))", event: .error)
                                    self?.errors.append(error.localizedDescription)
                                }
                                self?.dispatchGroup.leave()
                            })
                        case let .failure(error):
                            Log("Obtaining extractions from document with id \(createdDocument.id) failed with error: \(String(describing: error))", event: .error)
                            self?.errors.append(error.message)
                            self?.dispatchGroup.leave()
                        }
                    }
                case .failure(let error):
                    Log("Document creation failed: \(String(describing: error))", event: .error)
                    self?.errors.append(error.message)
                    self?.dispatchGroup.leave()
                }
            }
        }
    }
}

extension InvoicesListViewModel: PaymentComponentsControllerProtocol {
    func didTapOnMoreInformations(documentID: String?) {
        // MARK: TODO in next tasks
        guard let documentID else { return }
        Log("Tapped on More Information on :\(documentID)", event: .success)
    }
    
    func didTapOnBankPicker(documentID: String?) {
        // MARK: TODO in next tasks
        guard let documentID else { return }
        Log("Tapped on Bank Picker on :\(documentID)", event: .success)
    }
    
    func didTapOnPayInvoice(documentID: String?) {
        // MARK: TODO in next tasks
        guard let documentID else { return }
        Log("Tapped on Pay Invoice on :\(documentID)", event: .success)
    }
    
    func isLoadingStateChanged(isLoading: Bool) {
        if isLoading {
            self.coordinator.invoicesListViewController.showActivityIndicator()
        } else {
            self.coordinator.invoicesListViewController.hideActivityIndicator()
        }
    }
}
