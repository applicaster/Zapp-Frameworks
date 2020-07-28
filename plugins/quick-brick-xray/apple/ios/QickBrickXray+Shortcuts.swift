//
//  QickBrickXray.swift
//  QickBrickXray
//
//  Created by Alex Zchut on 27/08/2020.
//  Copyright © 2020 Applicaster Ltd. All rights reserved.
//

import Reporter
import UIKit
import XrayLogger
import ZappCore

struct ShortcutsUserInfoKeys {
    static let urlScheme = "url"
    static let identifier = "identifier"
}

extension QickBrickXray {
    var loggerViewShortcut: UIApplicationShortcutItem {
        let loggerViewTitle = "Present Logger View"
        let identifier = "loggerView"

        let urlScheme = "miami://plugin?pluginIdentifier=xray_logging_plugin&action=\(identifier)"
        return UIApplicationShortcutItem(type: loggerViewTitle,
                                         localizedTitle: loggerViewTitle,
                                         localizedSubtitle: nil,
                                         icon: UIApplicationShortcutIcon(type: .bookmark),
                                         userInfo: [ShortcutsUserInfoKeys.urlScheme: urlScheme,
                                                    ShortcutsUserInfoKeys.identifier: identifier] as [String: NSSecureCoding])
    }

    var shareEmailShortcut: UIApplicationShortcutItem {
        let identifier = "shareLogs"
        let shareLogsTitle = "Share Logs"
        let urlScheme = "miami://plugin?pluginIdentifier=xray_logging_plugin&action=\(identifier)"
        return UIApplicationShortcutItem(type: shareLogsTitle,
                                         localizedTitle: shareLogsTitle,
                                         localizedSubtitle: nil,
                                         icon: UIApplicationShortcutIcon(type: .share),
                                         userInfo: [ShortcutsUserInfoKeys.urlScheme: urlScheme,
                                                    ShortcutsUserInfoKeys.identifier: identifier] as [String: NSSecureCoding])
    }

    func shortcutsWasNotAdded() -> Bool {
        guard let shortcutItems = UIApplication.shared.shortcutItems else {
            return true
        }
        let result = shortcutItems.first { (shortcutItem) -> Bool in
            guard let identifier = shortcutItem.userInfo?[ShortcutsUserInfoKeys.identifier] as? String else {
                return false
            }
            return Bool(identifier) ?? false
        }
        return result != nil
    }

    func preparePlatform() {
        var shortcutItems = UIApplication.shared.shortcutItems ?? []
        if shortcutItems.isEmpty || shortcutsWasNotAdded() {
            shortcutItems += [loggerViewShortcut,
                              shareEmailShortcut]
        }
        UIApplication.shared.shortcutItems = shortcutItems
    }
}
