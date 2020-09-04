//
//  QickBrickXray.swift
//  QickBrickXray
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
    var shortcutEnabled: Bool = false
    var fileLogLevel: LogLevel?

    func merge(highPriority settings: Settings) -> Settings {
        var newSettings = Settings(shortcutEnabled: shortcutEnabled,
                                   fileLogLevel: fileLogLevel)
        newSettings.shortcutEnabled = settings.shortcutEnabled
        
        if let fileLogLevel = settings.fileLogLevel {
            newSettings.fileLogLevel = fileLogLevel
        }

        return newSettings
    }
}
