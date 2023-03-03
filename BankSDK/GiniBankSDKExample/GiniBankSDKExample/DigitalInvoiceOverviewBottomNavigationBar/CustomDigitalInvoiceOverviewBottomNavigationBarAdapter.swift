//
//  CustomDigitalInvoiceOverviewBottomNavigationBarAdapter.swift
//  GiniBankSDKExample
//
//  Created by David Vizaknai on 02.03.2023.
//

import UIKit
import GiniBankSDK

class CustomDigitalInvoiceOverviewBottomNavigationBarAdapter: DigitalInvoiceOverviewNavigationBarBottomAdapter {
    private var view: CustomDigitalInvoiceOverviewBottomNavigationBar?
    private var proceedButtonCallback: (() -> Void)?
    private var helpButtonCallback: (() -> Void)?

    func setProceedButtonClickedActionCallback(_ callback: @escaping () -> Void) {
        proceedButtonCallback = callback
    }

    func setHelpButtonClickedActionCallback(_ callback: @escaping  () -> Void) {
        helpButtonCallback = callback
    }

    func updateButtonState(enalbed: Bool) {
        view?.setProceedButtonState(enabled: enalbed)
    }

    func updateTotalPrice(with price: String?) {
        view?.updatePrice(with: price)
    }

    func setupViewsRelated(to view: UIView) {
        self.view?.setupConstraints(relatedTo: view)
    }

    func injectedView() -> UIView {
        let navigationBar = CustomDigitalInvoiceOverviewBottomNavigationBar()
        navigationBar.payButton.addTarget(self, action: #selector(proceedButtonClicked), for: .touchUpInside)
        navigationBar.helpButton.addTarget(self, action: #selector(helpButtonClicked), for: .touchUpInside)
        view = navigationBar
        return navigationBar
    }

    func onDeinit() {

    }

    @objc private func proceedButtonClicked() {
        proceedButtonCallback?()
    }

    @objc private func helpButtonClicked() {
        helpButtonCallback?()
    }
}
