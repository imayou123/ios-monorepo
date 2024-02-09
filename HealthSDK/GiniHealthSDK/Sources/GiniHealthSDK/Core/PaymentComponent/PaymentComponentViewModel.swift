//
//  PaymentComponentViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniHealthAPILibrary

/**
 Delegate to inform about the actions happened of the custom payment component view.
 You may find out when the user tapped on more information area, on the payment provider picker or on the pay invoice button

 */
public protocol PaymentComponentViewProtocol: AnyObject {
    /**
     Called when the user tapped on the more information actionable label or the information icon

     - parameter documentID: Id of document
     */
    func didTapOnMoreInformation(documentID: String?)

    /**
     Called when the user tapped on payment provider picker to change the selected payment provider or install it

     - parameter documentID: Id of document
     */
    func didTapOnBankPicker(documentID: String?)

    /**
     Called when the user tapped on the pay the invoice button to pay the invoice/document
     - parameter documentID: Id of document
     */
    func didTapOnPayInvoice(documentID: String?)
}

/**
 Helping extension for using the PaymentComponentViewProtocol methods without the document ID. This should be kept by the document view model and passed hierarchically from there.

 */
extension PaymentComponentViewProtocol {
    public func didTapOnMoreInformation() {
        didTapOnMoreInformation(documentID: nil)
    }
    public func didTapOnBankPicker() {
        didTapOnBankPicker(documentID: nil)
    }
    public func didTapOnPayInvoice() {
        didTapOnPayInvoice(documentID: nil)
    }
}

final class PaymentComponentViewModel {
    private var giniHealth: GiniHealth

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
    let selectYourBankLabelText = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.selectYourBank.label", comment: "")
    let selectYourBankLabelFont: UIFont
    let selectYourBankAccentColor: UIColor = GiniColor(lightModeColor: UIColor.GiniColors.dark1,
                                                   darkModeColor: UIColor.GiniColors.light1).uiColor()
    
    // Select bank picker
    let selectBankPickerViewBackgroundColor: UIColor = GiniColor(lightModeColor: UIColor.GiniColors.dark6, 
                                                                 darkModeColor: UIColor.GiniColors.light6).uiColor()
    let selectBankPickerViewBorderColor: UIColor = GiniColor(lightModeColor: UIColor.GiniColors.dark5,
                                                             darkModeColor: UIColor.GiniColors.light5).uiColor()
    private var bankImageIconData: Data?
    var bankImageIcon: UIImage {
        if let bankImageIconData {
            return UIImage(data: bankImageIconData) ?? UIImage()
        }
        return UIImage()
    }

    private var bankName: String?
    var bankNameLabelText: String {
        if let bankName, !bankName.isEmpty {
            return isPaymentProviderInstalled ? bankName : placeholderBankNameText
        }
        return placeholderBankNameText
    }
    var bankNameLabelFont: UIFont
    let bankNameLabelAccentColor: UIColor = GiniColor(lightModeColor: UIColor.GiniColors.dark1,
                                                      darkModeColor: UIColor.GiniColors.light1).uiColor()
    private let placeholderBankNameText: String = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.selectBank.label", comment: "")
    let chevronDownIconName: String = "iconChevronDown"
    let chevronDownIconColor: UIColor = GiniColor(lightModeColor: UIColor.GiniColors.light7,
                                                  darkModeColor: UIColor.GiniColors.light1).uiColor()

    // pay invoice view background color
    var payInvoiceViewBackgroundColor: UIColor {
        if let payInvoiceViewBackgroundColorString, let backgroundHexColor = payInvoiceViewBackgroundColorString.toColor() {
            return isPaymentProviderInstalled ? backgroundHexColor : defaultPayInvoiceViewBackgroundColor.withAlphaComponent(0.4)
        }
        return defaultPayInvoiceViewBackgroundColor.withAlphaComponent(0.4)
    }
    private let payInvoiceViewBackgroundColorString: String?
    private let defaultPayInvoiceViewBackgroundColor: UIColor = UIColor.GiniColors.accent1

    // pay invoice view text color
    let payInvoiceLabelText: String = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.payInvoice.label", comment: "")
    var payInvoiceLabelAccentColor: UIColor {
        if let payInvoiceLabelAccentColorString, let textHexColor = payInvoiceLabelAccentColorString.toColor() {
            return textHexColor
        }
        return defaultpayInvoiceLabelAccentColorString
    }
    private let payInvoiceLabelAccentColorString: String?
    private let defaultpayInvoiceLabelAccentColorString: UIColor = UIColor.GiniColors.dark7

    // pay invoice view font
    let payInvoiceLabelFont: UIFont

    var isPaymentProviderInstalled: Bool {
        if let paymentProviderScheme, let url = URL(string: paymentProviderScheme), UIApplication.shared.canOpenURL(url) {
            return true
        }
        return false
    }
    private var paymentProviderScheme: String?

    weak var delegate: PaymentComponentViewProtocol?
    
    init(paymentProvider: PaymentProvider?,
         giniHealth: GiniHealth) {
        self.giniHealth = giniHealth

        let defaultRegularFont: UIFont = GiniHealthConfiguration.shared.customFont.regular
        let defaultBoldFont: UIFont = GiniHealthConfiguration.shared.customFont.regular
        let defaultMediumFont: UIFont = GiniHealthConfiguration.shared.customFont.medium
        self.moreInformationLabelFont = GiniHealthConfiguration.shared.textStyleFonts[.caption1] ?? defaultRegularFont
        self.moreInformationLabelLinkFont = GiniHealthConfiguration.shared.textStyleFonts[.linkBold] ?? defaultBoldFont
        self.selectYourBankLabelFont = GiniHealthConfiguration.shared.textStyleFonts[.subtitle2] ?? defaultMediumFont
        self.bankNameLabelFont = GiniHealthConfiguration.shared.textStyleFonts[.input] ?? defaultMediumFont
        self.payInvoiceLabelFont = GiniHealthConfiguration.shared.textStyleFonts[.button] ?? defaultBoldFont
        
        self.bankImageIconData = paymentProvider?.iconData
        self.bankName = paymentProvider?.name
        self.payInvoiceViewBackgroundColorString = paymentProvider?.colors.background
        self.payInvoiceLabelAccentColorString = paymentProvider?.colors.text
        self.paymentProviderScheme = paymentProvider?.appSchemeIOS
    }
    
    func tapOnMoreInformation() {
        delegate?.didTapOnMoreInformation()
    }
    
    func tapOnBankPicker() {
        delegate?.didTapOnBankPicker()
    }
    
    func tapOnPayInvoiceView() {
        delegate?.didTapOnPayInvoice()
    }
}

