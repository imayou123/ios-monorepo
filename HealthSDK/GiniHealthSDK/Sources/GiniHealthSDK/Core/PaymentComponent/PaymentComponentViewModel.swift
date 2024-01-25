//
//  PaymentComponentViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

public protocol PaymentComponentViewModelProtocol: AnyObject {
    func didTapOnMoreInformations()
    func didTapOnBankPicker()
    func didTapOnPayInvoice()
}

final class PaymentComponentViewModel {
    
    var giniConfiguration: GiniHealthConfiguration

    let backgroundColor: UIColor = UIColor.from(giniColor: GiniColor(lightModeColor: .clear, 
                                                                     darkModeColor: .clear))
    
    // More information part
    let moreInformationAccentColor: UIColor = GiniColor(lightModeColor: UIColor.GiniColors.dark2, 
                                                        darkModeColor: UIColor.GiniColors.light4).uiColor()
    let moreInformationLabelText = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.moreInformation.label", comment: "")
    let moreInformationActionablePartText = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.moreInformation.underlined.part", comment: "")
    var moreInformationLabelFont: UIFont
    var moreInformationLabelLinkFont: UIFont
    let moreInformationIconName = "info.circle"
    
    // Select bank label
    let selectBankLabelText = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.selectBank.label", comment: "")
    let selectBankLabelFont: UIFont
    let selectBankAccentColor: UIColor = GiniColor(lightModeColor: UIColor.GiniColors.dark1, 
                                                   darkModeColor: UIColor.GiniColors.light1).uiColor()
    
    // Select bank picker
    let selectBankPickerViewBackgroundColor: UIColor = GiniColor(lightModeColor: UIColor.GiniColors.dark6, 
                                                                 darkModeColor: UIColor.GiniColors.light6).uiColor()
    let selectBankPickerViewBorderColor: UIColor = GiniColor(lightModeColor: UIColor.GiniColors.dark5,
                                                             darkModeColor: UIColor.GiniColors.light5).uiColor()
    var bankImageIconName: String
    var bankNameLabelText: String
    var bankNameLabelFont: UIFont
    let bankNameLabelAccentColor: UIColor = GiniColor(lightModeColor: UIColor.GiniColors.dark1, 
                                                      darkModeColor: UIColor.GiniColors.light1).uiColor()
    let chevronDownIconName: String = "iconChevronDown"
    
    // pay invoice view
    let payInvoiceViewBackgroundColor: UIColor
    let payInvoiceLabelText: String = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.payInvoice.label", comment: "")
    let payInvoiceLabelAccentColor: UIColor
    let payInvoiceLabelFont: UIFont
    
    weak var delegate: PaymentComponentViewModelProtocol?
    
    init(giniConfiguration: GiniHealthConfiguration, 
         bankName: String,
         bankIconName: String, 
         payInvoiceAccentColor: GiniColor,
         payInvoiceTextColor: GiniColor) {
        self.giniConfiguration = giniConfiguration
        self.moreInformationLabelFont = giniConfiguration.customFont.with(weight: .regular, 
                                                                          size: 13,
                                                                          style: .caption1)
        self.moreInformationLabelLinkFont = giniConfiguration.customFont.with(weight: .bold, 
                                                                              size: 14,
                                                                              style: .linkBold)
        self.selectBankLabelFont = giniConfiguration.customFont.with(weight: .medium, 
                                                                     size: 14,
                                                                     style: .subtitle2)
        self.bankImageIconName = bankIconName
        self.bankNameLabelText = bankName
        self.bankNameLabelFont = giniConfiguration.customFont.with(weight: .medium,
                                                                   size: 16, 
                                                                   style: .input)
        self.payInvoiceViewBackgroundColor = payInvoiceAccentColor.uiColor()
        self.payInvoiceLabelAccentColor = payInvoiceTextColor.uiColor()
        self.payInvoiceLabelFont = giniConfiguration.customFont.with(weight: .bold, size: 16, style: .button)
    }
    
    func tapOnMoreInformation() {
        delegate?.didTapOnMoreInformations()
    }
    
    func tapOnBankPicker() {
        delegate?.didTapOnBankPicker()
    }
    
    func tapOnPayInvoiceView() {
        delegate?.didTapOnPayInvoice()
    }
}

