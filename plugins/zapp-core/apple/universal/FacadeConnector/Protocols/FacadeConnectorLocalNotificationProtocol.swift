//
//  FacadeConnectorLocalNotificationProtocol.swift
//  ZappCore
//
//  Created by Anton Kononenko on 3/13/20.
//

import Foundation

@objc public protocol FacadeConnectorLocalNotificationProtocol {
    /// Cancel previously scheduled Local Notifications
    /// - Parameters:
    ///   - identifiers: Array of identifiers to cancel
    ///   - completion: Completion handler when task will be finished
    func cancelLocalNotifications(_ identifiers: [String]?,
                                  completion: @escaping (_ scheduled: Bool, _ error: Error?) -> Void)

    /// Schedule Local Notification task
    /// - Parameters:
    ///   - payload: Dictionary that contains data for creation Local Notification
    ///   - completion: Completion handler when task will be finished
    func presentLocalNotification(_ payload: [AnyHashable: Any],
                                  completion: @escaping (_ scheduled: Bool, _ error: Error?) -> Void)
}
