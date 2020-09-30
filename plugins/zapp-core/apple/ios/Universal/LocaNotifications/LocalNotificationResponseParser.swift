//
//  LocalNotificationResponseParser.swift
//  ZappCore
//
//  Created by Anton Kononenko on 3/18/20.
//

import Foundation

public class LocalNotificationResponseParser {
    
    /// Retrieve url from Local Notification Data
    /// - Parameter response: Recieved instance of the fired Local Notification
    public class func urlFromLocalNotification(response: UNNotificationResponse) -> URL? {
        let payload = response.notification.request.content.userInfo
        let actionIdentifier = response.actionIdentifier

        if let url = findUrlInActionsPayload(payload: payload,
                                             actionIdentifier: actionIdentifier) {
            return url
        } else if let url = findUrlForDefaultActionsPayload(payload: payload,
                                                            actionIdentifier: actionIdentifier) {
            return url
        } else if let url = findUrlInPayload(payload: payload) {
            return url
        }
        return nil
    }
    
    /// Check if should open the url with internal safari browser
    /// - Parameters:
    ///   - payload: Dictionary that contains data for creation Local Notification
    public class func urlToPresentModallyWithSafari(response: UNNotificationResponse) -> URL? {
        let payload = response.notification.request.content.userInfo
        let shouldOpenExternally = boolValue(for: payload[LocalNotificationPayloadConst.external])
        
        guard let url = findUrlInPayload(payload: payload),
              shouldOpenExternally == false,
              ["http", "https"].contains(url.scheme?.lowercased()) else {
            return nil
        }
        
        return url
    }
    
    class func boolValue(for content: Any?) -> Bool {
        var retVal = false

        // Check if value bool or string
        if let content = content as? String {
            if let contentBool = Bool(content) {
                retVal = contentBool
            } else if let contentInt = Int(content) {
                retVal = Bool(truncating: contentInt as NSNumber)
            }
        }
        else if let content = content as? Bool {
            retVal = content
        }
        return retVal
    }

    /// Retrieve url from payload
    /// - Parameters:
    ///   - payload: Dictionary that contains data for creation Local Notification
    class func findUrlInPayload(payload: [AnyHashable: Any]) -> URL? {

        if let urlString = payload[LocalNotificationPayloadConst.url] as? String,
            let url = URL(string: urlString) {
            return url
        }
        return nil
    }
    
    /// Retrieve url from payload data if default action match requested idenifier
    /// - Parameters:
    ///   - payload: Dictionary that contains data for creation Local Notification
    ///   - actionIdentifier: Unique identifier of the action  that user selected
    class func findUrlForDefaultActionsPayload(payload: [AnyHashable: Any],
                                               actionIdentifier: String) -> URL? {
        let defaultActionKey = defaultActionKeyFromActionIdentifier(actionIdentifier: actionIdentifier)

        return urlFromPayloadForDefaultKey(payload: payload,
                                           key: defaultActionKey)
    }

    /// Retrieve default action key from user selected action
    /// - Parameter actionIdentifier: Unique identifier of the action  that user selected
    class func defaultActionKeyFromActionIdentifier(actionIdentifier: String) -> String? {
        if actionIdentifier == UNNotificationDismissActionIdentifier {
            return LocalNotificationPayloadConst.dismissActionUrl
        } else if actionIdentifier == UNNotificationDefaultActionIdentifier {
            return LocalNotificationPayloadConst.defaultActionUrl
        }
        return nil
    }

    /// Retrieve url from payload for requested key
    /// - Parameters:
    ///   - payload: Dictionary that contains data for creation Local Notification
    ///   - key: Key that will be used to retrieve url
    class func urlFromPayloadForDefaultKey(payload: [AnyHashable: Any],
                                           key: String?) -> URL? {
        guard let key = key else {
            return nil
        }

        if let urlString = payload[key] as? String,
            let url = URL(string: urlString) {
            return url
        }
        return nil
    }

    /// Retrieve url from actions data if identifier match requested idenifier
    /// - Parameters:
    /// - Parameter payload: Dictionary that contains data for creation Local Notification
    ///   - actionIdentifier: Unique identifier of the action  that user selected
    class func findUrlInActionsPayload(payload: [AnyHashable: Any],
                                       actionIdentifier: String) -> URL? {
        if let actions = actionsFromPayload(payload: payload) {
            for buttonData in actions {
                if let url = urlFromAction(actionData: buttonData, actionIdentifier: actionIdentifier) {
                    return url
                }
            }
        }
        return nil
    }

    /// Retrieve actions array from Local notification Payload
    /// - Parameter payload: Dictionary that contains data for creation Local Notification
    class func actionsFromPayload(payload: [AnyHashable: Any]) -> [[AnyHashable: String]]? {
        guard let actions = payload[LocalNotificationPayloadConst.actions] as? [[AnyHashable: String]] else {
            return nil
        }
        return actions
    }

    /// Retrieve URL from Action Button if it contians required action identifier
    /// - Parameters:
    ///   - actionData: Dictionary for single action data
    ///   - actionIdentifier: Unique identifier of the action  that user selected
    class func urlFromAction(actionData: [AnyHashable: String], actionIdentifier: String) -> URL? {
        guard let urlString = actionData[LocalNotificationPayloadActions.url],
            let identifier = actionData[LocalNotificationPayloadActions.identifier],
            identifier == actionIdentifier,
            let url = URL(string: urlString) else {
            return nil
        }
        return url
    }
}
