//
//  ReactNativeManager+UserInterfaceLayerApplicationDelegate.swift
//  QuickBrickApple
//
//  Created by Anton Kononenko on 12/24/19.
//

import Foundation
import React
import ZappCore

extension ReactNativeManager: UIApplicationDelegate {
    public func application(_ app: UIApplication,
                            open url: URL,
                            options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return RCTLinkingManager.application(app,
                                             open: url,
                                             options: options)
    }

    public func application(_ application: UIApplication,
                            continue userActivity: NSUserActivity,
                            restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        return RCTLinkingManager.application(application,
                                             continue: userActivity,
                                             restorationHandler: restorationHandler)
    }
}
