//
//  AppleUserActivityBridge.swift
//  AppleUserActivity
//
//  Created by Alex Zchut on 02/11/2020.
//  Copyright © 2020 Applicaster Ltd. All rights reserved.
//

import Foundation
import React
import ZappCore
import MediaPlayer

@objc(AppleUserActivityBridge)
class AppleUserActivityBridge: NSObject, RCTBridgeModule {
    let pluginIdentifier = "quick-brick-apple-user-activity"
    var bridge: RCTBridge!
    var userActivity: NSUserActivity?
    static func moduleName() -> String! {
        return "AppleUserActivityBridge"
    }

    public class func requiresMainQueueSetup() -> Bool {
        return true
    }

    @objc public func defineUserActivity(_ params: NSDictionary) {
        
        guard let bundleIdentifier = FacadeConnector.connector?.storage?.sessionStorageValue(for: "bundleIdentifier",
                                                                                             namespace: nil),
            let contentId = params["content_id"] as? String else {
            return
        }
        
        //initialize the activity
        userActivity = NSUserActivity(activityType: "\(bundleIdentifier).details")
        
        //set external identifier
        userActivity?.externalMediaContentIdentifier = contentId
        
        DispatchQueue.main.async {
            //get current RN view controller
            guard let currentViewController = RCTPresentedViewController() else {
                return
            }
            
            //set and activate user activity
            currentViewController.userActivity = self.userActivity
            currentViewController.userActivity?.becomeCurrent()
        }
    }
    
    @objc public func removeUserActivity() {
        DispatchQueue.main.async {
            //get current RN view controller
            guard let currentViewController = RCTPresentedViewController() else {
                return
            }
            
            //set and activate user activity
            currentViewController.userActivity?.invalidate()
        }
    }
}
