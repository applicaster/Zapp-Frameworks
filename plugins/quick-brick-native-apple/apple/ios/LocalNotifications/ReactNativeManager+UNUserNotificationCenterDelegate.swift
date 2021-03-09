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

    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
        guard let url = LocalNotificationResponseParser.urlFromLocalNotification(response: response) else {
            completionHandler()
            return
        }
        UIApplication.shared.open(url, options: [:]) { _ in
            completionHandler()
        }
    }
}
