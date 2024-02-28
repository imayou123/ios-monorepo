//
//  AnalyticsManager.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import AmplitudeSwift
import UIKit

private let amplitudeKey = "22801da20bf476f5b4ecd4b86e717cb2"

class AnalyticsManager {
    static var adjustProperties: [AnalyticsProperty]?
    
    static let amplitude = Amplitude(configuration: Configuration(apiKey: "22801da20bf476f5b4ecd4b86e717cb2",
                                                                  defaultTracking: DefaultTrackingOptions(
                                                                    sessions: true,
                                                                    appLifecycles: false,
                                                                    screenViews: false
                                                                  )))

    static func initializeAnalytics() {
//        Amplitude.instance().initializeApiKey(amplitudeKey)

        let deviceID = UIDevice.current.identifierForVendor?.uuidString

//        Amplitude.instance().setDeviceId(deviceID ?? "")
        amplitude.setDeviceId(deviceId: deviceID ?? "")
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

        if let screenName = screenName {
            commonProperties["screen"] = screenName
        }

//        commonProperties["gini_client_id"] = SessionManager.client.clientId

        for property in properties {
            commonProperties[property.key] = property
        }

        let properties = commonProperties
        amplitude.track(eventType: event, eventProperties: properties)
//        Amplitude.instance().logEvent(event, withEventProperties: properties)
    }

}

struct AnalyticsProperty {
    let key: String
    var value: String
}
