//
//  PaymentProvider.swift
//  GiniHealthAPI
//
//  Created by Nadya Karaban on 15.03.21.
//

import Foundation

/**
 Struct for MinAppVersions in payment provider response
 */
public struct MinAppVersions: Codable {
    var ios: String?
    var android: String?
    public init(ios: String?, android: String?) {
        self.ios = ios
        self.android = android
    }
}
/**
 Struct for payment provider response
 */
public struct PaymentProvider: Codable {
    public var id: String
    public var name: String
    public var appSchemeIOS: String
    var minAppVersion: MinAppVersions?

    public init(id: String, name: String, appSchemeIOS: String, minAppVersion: MinAppVersions?) {
        self.id = id
        self.name = name
        self.appSchemeIOS = appSchemeIOS
        self.minAppVersion = minAppVersion
    }
}
public typealias PaymentProviders = [PaymentProvider]
