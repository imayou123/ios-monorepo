//
//  InvoiceTableViewCell.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

final class InvoiceTableViewCell: UITableViewCell {
    
    static let identifier = "InvoiceTableViewCell"
    
    var cellViewModel: InvoiceTableViewCellModel? {
        didSet {
            recipientLabel.text = cellViewModel?.recipientNameText
            recipientLabel.accessibilityValue = cellViewModel?.recipientNameText
            recipientLabel.isAccessibilityElement = true
            dueDateLabel.text = cellViewModel?.dueDateText
            dueDateLabel.accessibilityValue = cellViewModel?.dueDateText
            dueDateLabel.isAccessibilityElement = true
            amountLabel.text = cellViewModel?.amountToPayText
            amountLabel.accessibilityValue = cellViewModel?.amountToPayText
            amountLabel.isAccessibilityElement = true
            
            recipientLabel.isHidden = cellViewModel?.isRecipientLabelHidden ?? false
            dueDateLabel.isHidden = cellViewModel?.isDueDataLabelHidden ?? false
            
            if cellViewModel?.shouldShowPaymentComponent ?? false, let paymentComponentView = cellViewModel?.paymentComponentView {
                mainStackView.addArrangedSubview(paymentComponentView)
            }
        }
    }

    @IBOutlet private weak var mainStackView: UIStackView!
    @IBOutlet private weak var recipientLabel: UILabel!
    @IBOutlet private weak var dueDateLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        self.isAccessibilityElement = false
        mainStackView.isAccessibilityElement = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if mainStackView.arrangedSubviews.count > 1 {
            mainStackView.arrangedSubviews.last?.removeFromSuperview()
        }
    }
}
