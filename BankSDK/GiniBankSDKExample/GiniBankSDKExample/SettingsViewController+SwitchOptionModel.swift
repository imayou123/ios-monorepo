//
//  SettingsViewController+SwitchOptionModel.swift
//  GiniBankSDKExample
//
//  Created by Valentina Iancu on 16.06.23.
//

struct SwitchOptionModel {
	let type: OptionType
	var isActive: Bool
	
	enum OptionType {
		case openWith
		case qrCodeScanning
		case qrCodeScanningOnly
		case multipage
		case flashToggle
		case flashOnByDefault
		case bottomNavigationBar
		case onboardingShowAtLaunch
		case customOnboardingPages
		case onButtonLoadingIndicator
		
		var title: String {
			switch self {
			case .openWith:
				return "Open with"
			case .qrCodeScanning:
				return "QR code scanning"
			case .qrCodeScanningOnly:
				return "QR code scanning only"
			case .multipage:
				return "Multipage"
			case .flashToggle:
				return "Flash Toggle"
			case .flashOnByDefault:
				return "Flash ON by default"
			case .bottomNavigationBar:
				return "Bottom navigation bar"
			case .onboardingShowAtLaunch:
				return "Show Onboarding screens at launch"
			case .customOnboardingPages:
				return "Set custom onboarding pages"
			case .onButtonLoadingIndicator:
				return "Set custom loading indicator on the buttons"
			}
		}
		
		var message: String? {
			switch self {
			case .qrCodeScanningOnly:
				return "This will work if the `qrCodeScanning` switch is also enabled."
			case .flashOnByDefault:
				return "This will work if the `flashToggle` switch is also enabled."
			case .customOnboardingPages:
				return "This will work if the `onboardingShowAtLaunch` switch is also enabled."
			default:
				return nil
			}
		}
	}
}
