//
//  CGFloat.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit

extension CGFloat {
    var scaledSize: CGFloat {
        UIFontMetrics.default.scaledValue(for: self)
    }
}
