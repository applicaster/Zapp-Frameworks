//
//  ReactNativeManager+UNUserNotificationCenterDelegate.swift
//  QuickBrickApple
//
//  Created by Anton Kononenko on 3/18/20.
//

import Foundation
import React
import ZappCore

extension ReactNativeManager: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}
