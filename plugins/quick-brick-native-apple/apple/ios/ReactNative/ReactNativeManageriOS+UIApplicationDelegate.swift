//
//  ReactNativeManager+UserInterfaceLayerApplicationDelegate.swift
//  QuickBrickApple
//
//  Created by Anton Kononenko on 12/24/19.
//

import Foundation
import React
import ZappCore

extension ReactNativeManager {
    func getLink(userInfo: [AnyHashable: Any]) -> String? {
        if let url = userInfo["url"] as? String {
            return url
        } else if let url = userInfo["^d"] as? String {
            return url
        } else if let url = userInfo["^u"] as? String {
            return url
        }
        return nil
    }

    public func application(_ application: UIApplication,
                            didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
    }

    public func application(_ application: UIApplication,
                            didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                            fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let userInfo = userInfo
        if let urlString = getLink(userInfo: userInfo),
            let url = URL(string: urlString) {
            UIApplication.shared.open(url,
                                      options: [:],
                                      completionHandler: nil)
            
        }
        completionHandler(UIBackgroundFetchResult.newData)

    }

    public func applicationWillResignActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    public func application(_ application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    }

    public func application(_ application: UIApplication,
                            didFailToRegisterForRemoteNotificationsWithError error: Error) {
    }
}
