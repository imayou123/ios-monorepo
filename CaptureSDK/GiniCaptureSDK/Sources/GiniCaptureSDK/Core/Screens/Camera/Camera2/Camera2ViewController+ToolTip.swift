//
//  Camera2ViewController+Extension.swift
//  
//
//  Created by Krzysztof Kryniecki on 14/09/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import UIKit

extension Camera2ViewController {
    func showPopup(forQRDetected qrDocument: GiniQRCodeDocument, didTapDone: @escaping () -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            let newQRCodePopup = QRCodeDetectedPopupView(parent: self.view,
                                                         refView: self.cameraPreviewViewController.view,
                                                         document: qrDocument,
                                                         giniConfiguration: self.giniConfiguration)

            let didDismiss: () -> Void = { [weak self] in
                self?.detectedQRCodeDocument = nil
                self?.currentQRCodePopup = nil
            }

            if qrDocument.qrCodeFormat == nil {
                self.configurePopupViewForUnsupportedQR(newQRCodePopup, dismissCompletion: didDismiss)
            } else {
                newQRCodePopup.didTapDone = { [weak self] in
                    didTapDone()
                    self?.currentQRCodePopup?.hide(after: 0.0, completion: didDismiss)
                }
            }

            if self.currentQRCodePopup != nil {
                self.currentQRCodePopup?.hide { [weak self] in
                    self?.currentQRCodePopup = newQRCodePopup
                    self?.currentQRCodePopup?.show(didDismiss: didDismiss)
                }
            } else {
                self.currentQRCodePopup = newQRCodePopup
                self.currentQRCodePopup?.show(didDismiss: didDismiss)
            }
        }
    }

    fileprivate func configurePopupViewForUnsupportedQR(
        _ newQRCodePopup: QRCodeDetectedPopupView,
        dismissCompletion: @escaping () -> Void) {
            newQRCodePopup.backgroundColor = giniConfiguration.unsupportedQrCodePopupBackgroundColor.uiColor()
            newQRCodePopup.qrText.textColor =  giniConfiguration.unsupportedQrCodePopupTextColor.uiColor()
        newQRCodePopup.qrText.text = .localized(resource: CameraStrings.unsupportedQrCodeDetectedPopupMessage)
        newQRCodePopup.proceedButton.setTitle("✕", for: .normal)
        newQRCodePopup.proceedButton.setTitleColor(giniConfiguration.unsupportedQrCodePopupButtonColor, for: .normal)
        newQRCodePopup.proceedButton.setTitleColor(
            giniConfiguration.unsupportedQrCodePopupButtonColor.withAlphaComponent(0.5),
            for: .highlighted)
        newQRCodePopup.didTapDone = { [weak self] in
            self?.currentQRCodePopup?.hide(after: 0.0, completion: dismissCompletion)
        }
    }
}
