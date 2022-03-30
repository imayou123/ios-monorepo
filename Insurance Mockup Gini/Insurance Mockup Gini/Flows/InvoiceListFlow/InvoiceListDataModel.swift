//
//  InvoiceListDataModel.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 25.03.2022.
//

import Foundation
import GiniBankAPILibrary

final class InvoiceListDataModel {
    private static var dayTimeInterval: Double = 60*60*24
    var updateList: (() -> Void)?
    var updateInfoBannerVisibility: ((Bool) -> Void)?
    var invoiceData: [Invoice] = [
        {   var invoice = Invoice(extractions: [], document: nil)
            invoice.invoiceTitle = "Dr. Theresa Müller"
            invoice.price = 450.11
            invoice.creationDate = Date().addingTimeInterval(-1 * dayTimeInterval)
            return invoice
        }(),
        {   var invoice = Invoice(extractions: [], document: nil)
            invoice.invoiceTitle = "Dr. Mara Klinsmann"
            invoice.invoiceID = "5CF076CE-F548-403E-9F76-9768CC128E8E"
            invoice.iconTitle = "icon_dentist"
            invoice.price = 145.99
            invoice.creationDate = Date().addingTimeInterval(-4 * dayTimeInterval)
            return invoice
        }(),
        {   var invoice = Invoice(extractions: [], document: nil)
            invoice.invoiceTitle = "Dr. Mara Klinsmann"
            invoice.iconTitle = "icon_book"
            invoice.price = 145.99
            invoice.paid = true
            invoice.reimbursmentStatus = .sent
            invoice.creationDate = Date().addingTimeInterval(-7 * dayTimeInterval)
            return invoice
        }(),
        {   var invoice = Invoice(extractions: [], document: nil)
            invoice.invoiceTitle = "Universitätsklinikum Berlin"
            invoice.iconTitle = "icon_book"
            invoice.price = 45.12
            invoice.creationDate = Date().addingTimeInterval(-40 * dayTimeInterval)
            return invoice
        }(),
        {   var invoice = Invoice(extractions: [], document: nil)
            invoice.invoiceTitle = "Bayer Klinikum"
            invoice.iconTitle = "icon_dentist"
            invoice.price = 15.89
            invoice.paid = true
            invoice.reimbursmentStatus = .sent
            invoice.creationDate = Date().addingTimeInterval(-45 * dayTimeInterval)
            return invoice
        }(),
        {   var invoice = Invoice(extractions: [], document: nil)
            invoice.invoiceTitle = "Universitätsklinikum Frankfurt"
            invoice.iconTitle = "icon_book"
            invoice.price = 15.89
            invoice.paid = true
            invoice.reimbursmentStatus = .reimbursed
            invoice.creationDate = Date().addingTimeInterval(-45 * dayTimeInterval)
            return invoice
        }()
    ]

    lazy var invoiceList = invoiceData.sorted(by: { $0.creationDate > $1.creationDate }).map { InvoiceItemCellViewModel(invoice: $0) }

    func updateInvoice(paymentId: String, forInvoiceWith id: String) {
        guard let index = invoiceData.firstIndex(where: { $0.invoiceID == id }) else { return }
        var invoice = invoiceData[index]
        invoice.paymentRequestID = paymentId
        invoiceData[index] = invoice
    }

    func markInvoicePayed(forInvoiceWith id: String) {
        guard let index = invoiceData.firstIndex(where: { $0.invoiceID == id }) else { return }
        var invoice = invoiceData[index]
        invoice.paid = true
        invoiceData[index] = invoice
        updateInvoiceList()
    }

    func markInvoiceReimbursed(forInvoiceWith id: String) {
        guard let index = invoiceData.firstIndex(where: { $0.invoiceID == id }) else { return }
        var invoice = invoiceData[index]
        invoice.reimbursmentStatus = .sent
        if id == "5CF076CE-F548-403E-9F76-9768CC128E8E" {
            // Show the info banner only for this reimbursment action for the speific cell
            updateInfoBannerVisibility?(true)
        }
        invoiceData[index] = invoice
        updateInvoiceList()
    }

    func updateInvoiceList() {
        invoiceList = invoiceData.sorted(by: { $0.creationDate > $1.creationDate }).map { InvoiceItemCellViewModel(invoice: $0) }
        updateList?()
    }

    func addNewInvoice(invoice: Invoice) {
        invoiceData.append(invoice)
        updateInvoiceList()
    }
}
