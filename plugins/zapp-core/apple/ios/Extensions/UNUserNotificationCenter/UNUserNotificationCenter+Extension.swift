//
//  UNUserNotificationCenter+Extension.swift
//  ZappCore
//
//  Created by Alex Zchut on 17/06/2021.
//

extension UNUserNotificationCenter {
    public func decreaseBadgeCount(by notificationsRemoved: Int? = nil) {
        let notificationsRemoved = notificationsRemoved ?? 1
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber -= notificationsRemoved
        }
    }

    public func removeNotifications(_ notifications: [UNNotification], decreaseBadgeCount: Bool = false) {
        let identifiers = notifications.map { $0.request.identifier }
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifiers)
        if decreaseBadgeCount {
            self.decreaseBadgeCount(by: notifications.count)
        }
    }

    public func removeNotifications<T: Comparable>(whereKey key: AnyHashable, hasValue value: T, decreaseBadgeCount: Bool = false) {
        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
            let notificationsToRemove = notifications.filter {
                guard let userInfoValue = $0.request.content.userInfo[key] as? T else { return false }
                return userInfoValue == value
            }
            self.removeNotifications(notificationsToRemove, decreaseBadgeCount: decreaseBadgeCount)
        }
    }

    public func removeNotifications(withThreadIdentifier threadIdentifier: String, decreaseBadgeCount: Bool = false) {
        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
            let notificationsToRemove = notifications.filter { $0.request.content.threadIdentifier == threadIdentifier }
            self.removeNotifications(notificationsToRemove, decreaseBadgeCount: decreaseBadgeCount)
        }
    }

    public func removeNotification(_ notification: UNNotification, decreaseBadgeCount: Bool = false) {
        removeNotifications([notification], decreaseBadgeCount: decreaseBadgeCount)
    }
}
