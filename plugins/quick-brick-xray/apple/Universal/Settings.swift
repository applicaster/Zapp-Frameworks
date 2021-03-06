//
//  QuickBrickXray.swift
//  QuickBrickXray
//
//  Created by Anton Kononenko on 27/08/2020.
//  Copyright © 2020 Applicaster Ltd. All rights reserved.
//

import LoggerInfo
import Reporter
import UIKit
import XrayLogger
import ZappCore

struct Settings {
    var customSettingsEnabled: Bool = false {
        didSet {
            if customSettingsEnabled == true {
                let dayOffset: TimeInterval = 60 * 60 * 24
                customSettingsOffsetToDisable = Date(timeIntervalSinceNow: dayOffset)
            } else {
                customSettingsOffsetToDisable = nil
            }
        }
    }

    var customSettingsOffsetToDisable: Date?
    var showXrayFloatingButtonEnabled: Bool = false
    var shortcutEnabled: Bool = false
    var fileLogLevel: LogLevel?
    var networkRequestEnabled: Bool = false
    var networkRequestsIgnoredExtensions: [String] = []
    var networkRequestsIgnoredDomains:[String] = []

    var isCustomSettingsExpired: Bool {
        guard let customSettingsOffsetToDisable = customSettingsOffsetToDisable else {
            return false
        }
        return customSettingsEnabled && customSettingsOffsetToDisable <= Date()
    }

    static func == (lhs: Settings,
                    rhs: Settings) -> Bool {
        return
            lhs.customSettingsEnabled == rhs.customSettingsEnabled &&
            lhs.shortcutEnabled == rhs.shortcutEnabled &&
            lhs.fileLogLevel == rhs.fileLogLevel
    }

    static func != (lhs: Settings,
                    rhs: Settings) -> Bool {
        return (lhs == rhs) == false
    }
}
