//
//  InvoiceFlowCoordinator.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 21.03.2022.
//

import UIKit

final class InvoiceFlowCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var rootViewController: UIViewController {
        return navigationController
    }

    private var dataModel: InvoiceListDataModel

    var navigationController: UINavigationController!

    init(dataModel: InvoiceListDataModel) {
        self.dataModel = dataModel
    }

    func start() {
        let viewModel = InvoiceListViewModel(dataModel: dataModel)
        viewModel.delegate = self
        let viewController = InvoiceListViewController(viewModel: viewModel)
        navigationController = UINavigationController(rootViewController: viewController)

        navigationController.navigationBar.isHidden = true
    }

    func addNewInvoice(invoice: Invoice) {
        dataModel.addNewInvoice(invoice: invoice)
    }

    func showInvoiceDetail(with id: String) {
        didSelectInvoice(with: id)
    }
}

extension InvoiceFlowCoordinator: InvoiceListViewModelDelegate {
    func didSelectInvoice(with id: String) {
        let viewModel = InvoiceDetailViewModel(invoiceDetail: NewInvoiceDetailViewModel(invoice: Invoice(extractions: [], document: nil)))
        viewModel.delegate = self
        let viewController = InvoiceDetailViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension InvoiceFlowCoordinator: InvoiceDetailViewModelDelegate {
    func didTapBack() {
        navigationController.popViewController(animated: true)
    }
}
