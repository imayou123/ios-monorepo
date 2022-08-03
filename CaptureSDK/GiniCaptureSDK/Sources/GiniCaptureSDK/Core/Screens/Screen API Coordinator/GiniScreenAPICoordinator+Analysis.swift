//
//  GiniScreenAPICoordinator+Analysis.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 4/4/18.
//

import Foundation

// MARK: - Analysis Screen

extension GiniScreenAPICoordinator {
    func createAnalysisScreen(withDocument document: GiniCaptureDocument) -> AnalysisViewController {
        let viewController = AnalysisViewController(document: document)
        viewController.setupNavigationItem(usingResources: self.cancelButtonResource,
                                           selector: #selector(back),
                                           position: .left,
                                           target: self)
        return viewController
    }
}

// MARK: - ImageAnalysisNoResults screen

extension GiniScreenAPICoordinator {
    func createImageAnalysisNoResultsScreen() -> HelpTipsViewController {
        let imageAnalysisNoResultsViewController: HelpTipsViewController
        let isCameraViewControllerLoaded: Bool = {
            guard let cameraViewController = cameraViewController else {
                return false
            }
            return screenAPINavigationController.viewControllers.contains(cameraViewController)
        }()
        
        if isCameraViewControllerLoaded {
            imageAnalysisNoResultsViewController = HelpTipsViewController(giniConfiguration: giniConfiguration)
            imageAnalysisNoResultsViewController.setupNavigationItem(usingResources: backButtonResource,
                                                                     selector: #selector(backToCamera),
                                                                     position: .left,
                                                                     target: self)
        } else {
            imageAnalysisNoResultsViewController = HelpTipsViewController(giniConfiguration: giniConfiguration)
            imageAnalysisNoResultsViewController.setupNavigationItem(usingResources: closeButtonResource,
                                                                     selector: #selector(closeScreenApi),
                                                                     position: .left,
                                                                     target: self)
        }
        
        // TODO: no results screen
        /*
        imageAnalysisNoResultsViewController.didTapBottomButton = { [weak self] in
            self?.backToCamera()
        }*/
        
        return imageAnalysisNoResultsViewController
    }
}

// MARK: - AnalysisDelegate

extension GiniScreenAPICoordinator: AnalysisDelegate {
    public func displayError(withMessage message: String?, andAction action: (() -> Void)?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                let message = message,
                let action = action else { return }
            
            if let analysisViewController = self.analysisViewController {
                analysisViewController.showError(with: message, action: { [weak self] in
                    guard let self = self else { return }
                    self.analysisErrorAndAction = nil
                    action()
                })
            } else {
                self.analysisErrorAndAction = (message, action)
            }

        }
    }
    
    public func tryDisplayNoResultsScreen() -> Bool {
        if pages.type == .image {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.imageAnalysisNoResultsViewController = self.createImageAnalysisNoResultsScreen()
                self.screenAPINavigationController.pushViewController(self.imageAnalysisNoResultsViewController!,
                                                                      animated: true)
            }
            
            return true
        }
        return false
    }    
}
