//
//  NotificationService.swift
//  NotificationServiceExtension
//
//  Created by Alex Zchut on 09/01/2020.
//  Copyright © 2020 Applicaster LTD. All rights reserved.
//

import Firebase
import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    struct Params {
        static let supportedAppGroups = "SupportedAppGroups"
        static let configurationJSON = "configurationJSON"
        static let filteringKey = "notifications_filtering_key"
    }

    lazy var appGroup: String? = {
        guard let appGroups = Bundle.main.object(forInfoDictionaryKey: Params.supportedAppGroups) as? [String],
              appGroups.count > 0 else {
            return nil
        }

        return appGroups.first
    }()

    var userDefaults: UserDefaults? {
        guard let appGroup = appGroup,
              let userDefaults = UserDefaults(suiteName: appGroup) else {
            return nil
        }
        return userDefaults
    }

    lazy var configurationJSON: [String: Any]? = {
        guard let content = userDefaults?.dictionary(forKey: Params.configurationJSON) else {
            return nil
        }
        return content
    }()

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler

        // Determine whether you should suppress the notification.
        if shouldSuppressNotification(request: request) {
            contentHandler(UNNotificationContent())
        } else {
            bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

            guard let content = bestAttemptContent else {
                return
            }

            // add custom sound param
            if let sound = content.userInfo["sound"] as? String {
                let soundName = UNNotificationSoundName(sound)
                content.sound = UNNotificationSound(named: soundName)
            }

            Messaging.serviceExtension().populateNotificationContent(content, withContentHandler: contentHandler)
        }
    }

    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

    fileprivate func shouldSuppressNotification(request: UNNotificationRequest) -> Bool {
        var retValue = false
        guard let key = configurationJSON?[Params.filteringKey] as? String,
              let value = request.content.userInfo[key] as? String else {
            return retValue
        }

        if var values = userDefaults?.mutableArrayValue(forKey: key) as? [String] {
            if values.contains(value) {
                retValue = true
            } else {
                values.append(value)
                userDefaults?.setValue(values, forKey: key)
            }
        } else {
            userDefaults?.setValue([], forKey: key)
        }

        return retValue
    }
}
