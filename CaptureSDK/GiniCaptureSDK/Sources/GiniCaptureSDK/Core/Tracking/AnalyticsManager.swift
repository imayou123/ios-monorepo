//
//  AnalyticsManager.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import AmplitudeSwift
import UIKit
import Mixpanel

private let amplitudeKey = "22801da20bf476f5b4ecd4b86e717cb2"
private let mixPanelToken = "fec4cd2a3fdf4ca9d7e3f377ef7f6746"

class AnalyticsManager {
    static var adjustProperties: [AnalyticsProperty]?

    static let amplitude = Amplitude(configuration: Configuration(apiKey: amplitudeKey,
                                                                  defaultTracking: DefaultTrackingOptions(
                                                                    sessions: true,
                                                                    appLifecycles: false,
                                                                    screenViews: false
                                                                  )))

    static var mixpanelInstance: MixpanelInstance?
    static func initializeAnalytics() {
//        Amplitude.instance().initializeApiKey(amplitudeKey)

        let deviceID = UIDevice.current.identifierForVendor?.uuidString

//        Amplitude.instance().setDeviceId(deviceID ?? "")
        amplitude.setDeviceId(deviceId: deviceID ?? "")

        mixpanelInstance = Mixpanel.initialize(token: mixPanelToken, trackAutomaticEvents: false)
        mixpanelInstance?.identify(distinctId: deviceID ?? "")

    }

    static func trackScreenShown(screenName: String,
                                 properties: [AnalyticsProperty] = []) {
        track(event: "screen_shown",
              screenName: screenName,
              properties: properties)
    }

    static func track(event: String,
                      screenName: String? = nil,
                      properties: [AnalyticsProperty] = []) {
        var commonProperties: [String: Any] = [:]
        var mixPanelProperties: [String: String] = [:]

        if let screenName = screenName {
            commonProperties["screen"] = screenName
            mixPanelProperties["screen"] = screenName
        }

//        commonProperties["gini_client_id"] = SessionManager.client.clientId

        for property in properties {
            commonProperties[property.key] = property
            mixPanelProperties[property.key] = property.value
        }

        amplitude.track(eventType: event, eventProperties: commonProperties)
        mixpanelInstance?.track(event: event, properties: mixPanelProperties)
    }

}

struct AnalyticsProperty {
    let key: String
    var value: String
}
