//
//  DefaultOnboardingPage+Analytics.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation

protocol DefaultOnboardingPageAnalytics {
    var screenName: String { get }
}

extension DefaultOnboardingPage {
    var screenName: String {
        switch self {
            case .flatPaper:
                return "onboarding_flat_paper"
            case .lighting:
                return "onboarding_lighting"
            case .multipage:
                return "onboarding_multiple_pages"
            case .qrcode:
                return "onboarding_qr_code"
        }
    }
}
