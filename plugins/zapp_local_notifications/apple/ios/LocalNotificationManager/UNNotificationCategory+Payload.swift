//
//  UNNotificationCategory+Payload.swift
//  ZappLocalNotifications
//
//  Created by Anton Kononenko on 3/16/20.
//

import Foundation
import ZappCore

extension UNNotificationCategory {
    /// Basic category identifer without buttons
    static let baseCategoryIdentifier = "Default-Category"

    /// Cretate Category for local notification by payload dictionary
    /// - Parameter payload: Dictionary that contains data for creation Local Notification
    class func category(payload: [AnyHashable: Any]) -> UNNotificationCategory? {
        guard let actionsTuple = actionsButtonsFromPayload(payload: payload) else {
            return nil
        }

        return UNNotificationCategory(identifier: actionsTuple.categoryIdentifier,
                                      actions: actionsTuple.actionsButton,
                                      intentIdentifiers: [],
                                      options: [.customDismissAction])
    }

    /// Retrieves tuple of actions and category identifier from payload dictionary
    /// - Parameter payload: Dictionary that contains data for creation Local Notification
    class func actionsButtonsFromPayload(payload: [AnyHashable: Any]) -> (actionsButton: [UNNotificationAction], categoryIdentifier: String)? {
        guard let actions = payload[LocalNotificationPayloadConst.actions] as? [[AnyHashable: Any]] else {
            return nil
        }

        return actionsButtonForCategory(actions: actions)
    }

    /// Create availible for LocalNotification Actions buttons from actions data payload
    /// - Parameter actions: Dictionary with payload for all LocalNotification Action
    class func actionsButtonForCategory(actions: [[AnyHashable: Any]]) -> (actionsButton: [UNNotificationAction], categoryIdentifier: String) {
        var categoryIdentifier = baseCategoryIdentifier
        var actionButtons: [UNNotificationAction] = []

        for actionButtonData in actions {
            if let actionButton = actionFromActionButtonData(actionButtonData: actionButtonData) {
                let itemWithSameIdentifier = actionButtons.first { (notificationAction) -> Bool in
                    notificationAction.identifier == actionButton.identifier
                }
                if itemWithSameIdentifier == nil {
                    categoryIdentifier += "-\(actionButton.identifier)"
                    actionButtons.append(actionButton)
                }
            }
        }
        return (actionButtons, categoryIdentifier)
    }

    /// Create action item with payload dictionary for LocalNotification Action
    /// - Parameter actionButtonData: Dictionary with payload for LocalNotification Action
    class func actionFromActionButtonData(actionButtonData: [AnyHashable: Any]) -> UNNotificationAction? {
        var retVal: UNNotificationAction?

        guard let actionIdentifier = actionButtonData[LocalNotificationPayloadActions.identifier] as? String,
            let title = actionButtonData[LocalNotificationPayloadActions.title] as? String else {
            return nil
        }

        var options: UNNotificationActionOptions = [.foreground,
                                                    .authenticationRequired]
        if isButtonDestructive(actionButtonData: actionButtonData) {
            options.insert(.destructive)
        }

        retVal = UNNotificationAction(identifier: actionIdentifier,
                                      title: title,
                                      options: options)
        return retVal
    }

    /// Verify is button destructive
    /// - Parameter actionButtonData: Dictionary with payload for LocalNotification Action
    class func isButtonDestructive(actionButtonData: [AnyHashable: Any]) -> Bool {
        if let buttonType = actionButtonData[LocalNotificationPayloadActions.buttonType] as? String {
            if buttonType == LocalNotificationPayloadActions.ButtonType.danger {
                return true
            }
        }
        return false
    }
}
