//
//  QickBrickXray.swift
//  QickBrickXray
//
//  Created by Alex Zchut on 27/08/2020.
//  Copyright © 2020 Applicaster Ltd. All rights reserved.
//

import LoggerInfo
import Reporter
import UIKit
import XrayLogger
import ZappCore

struct ShortcutsUserInfoKeys {
    static let action = "action"
    static let namespace = "namespace"
}

enum ShortcutsActions: String {
    case presentLoggerInfo = "xray_logging_plugin_presentLoggerInfo"
    case shareLogs = "xray_logging_plugin_shareLogs"
}

extension QickBrickXray {
    var loggerViewShortcut: UIApplicationShortcutItem {
        let loggerViewTitle = "Present Logger View"

        return UIApplicationShortcutItem(type: loggerViewTitle,
                                         localizedTitle: loggerViewTitle,
                                         localizedSubtitle: nil,
                                         icon: UIApplicationShortcutIcon(type: .bookmark),
                                         userInfo: [ShortcutsUserInfoKeys.action: ShortcutsActions.presentLoggerInfo.rawValue,
                                                    ShortcutsUserInfoKeys.namespace: pluginNameSpace] as [String: NSSecureCoding])
    }

    var shareEmailShortcut: UIApplicationShortcutItem {
        let shareLogsTitle = "Share Logs"
        return UIApplicationShortcutItem(type: shareLogsTitle,
                                         localizedTitle: shareLogsTitle,
                                         localizedSubtitle: nil,
                                         icon: UIApplicationShortcutIcon(type: .share),
                                         userInfo: [ShortcutsUserInfoKeys.action: ShortcutsActions.shareLogs.rawValue,
                                                    ShortcutsUserInfoKeys.namespace: pluginNameSpace] as [String: NSSecureCoding])
    }

    func removePluginShortcuts() -> [UIApplicationShortcutItem]? {
        guard let shortcutItems = UIApplication.shared.shortcutItems else {
            return nil
        }
        let result = shortcutItems.filter { (shortcutItem) -> Bool in
            guard let identifier = shortcutItem.userInfo?[ShortcutsUserInfoKeys.action] as? String,
                identifier == ShortcutsActions.presentLoggerInfo.rawValue else {
                return false
            }
            return identifier != ShortcutsActions.presentLoggerInfo.rawValue && identifier != ShortcutsActions.shareLogs.rawValue
        }
        return result
    }

    func shortcutsWasNotAdded() -> Bool {
        guard let shortcutItems = UIApplication.shared.shortcutItems else {
            return true
        }
        let result = shortcutItems.first { (shortcutItem) -> Bool in
            guard let identifier = shortcutItem.userInfo?[ShortcutsUserInfoKeys.action] as? String,
                identifier == ShortcutsActions.presentLoggerInfo.rawValue else {
                return false
            }
            return Bool(identifier) ?? false
        }
        return result != nil
    }

    func prepareShortcuts() {
        addSessionStorageObserver()
        guard currentSettings?.shortcutEnabled == true else {
            UIApplication.shared.shortcutItems = removePluginShortcuts()
            return
        }

        var shortcutItems = UIApplication.shared.shortcutItems ?? []
        if shortcutItems.isEmpty || shortcutsWasNotAdded() {
            shortcutItems += [loggerViewShortcut,
                              shareEmailShortcut]
        }

        UIApplication.shared.shortcutItems = shortcutItems
    }

    func addSessionStorageObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAction),
                                               name: Notification.Name(sessionStorageObservationKey),
                                               object: nil)
    }

    @objc func handleAction(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let action = userInfo[ShortcutsUserInfoKeys.action] as? String else {
            return
        }

        if action == ShortcutsActions.presentLoggerInfo.rawValue {
            presentLoggerView()
        } else if action == ShortcutsActions.shareLogs.rawValue {
            Reporter.requestSendEmail()
        }
    }
}
