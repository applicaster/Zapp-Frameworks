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
import XrayLogger

@objc(AppleUserActivityBridge)
class AppleUserActivityBridge: NSObject, RCTBridgeModule {
    lazy var logger = Logger.getLogger(for: "\(kNativeSubsystemPath)/ScreenUserActivity")
    
    let pluginIdentifier = "quick-brick-apple-user-activity"
    let activityType = "qb.screen.useractivity.details"
    var bridge: RCTBridge!
    var userActivity: NSUserActivity!
    static func moduleName() -> String! {
        return "AppleUserActivityBridge"
    }

    public class func requiresMainQueueSetup() -> Bool {
        return true
    }

    @objc public func defineUserActivity(_ params: NSDictionary) {
        
        guard Bundle.main.hasActivity(for: activityType),
              let contentId = params["apple_user_activity_content_id"] as? String else {
            return
        }
        
        //initialize the activity
        userActivity = NSUserActivity(activityType: activityType)
        
        //set external identifier
        userActivity.externalMediaContentIdentifier = contentId
        
        DispatchQueue.main.async {
            //get current RN view controller
            guard let currentViewController = RCTPresentedViewController() else {
                return
            }
            
            //set and activate user activity
            currentViewController.userActivity = self.userActivity
            currentViewController.userActivity?.becomeCurrent()
            
            if let contentIdentifier = currentViewController.userActivity?.externalMediaContentIdentifier,
               let activityType = currentViewController.userActivity?.activityType {
                self.logger?.debugLog(message: "Setting userActivity for show screen",
                                      data: ["activityType": activityType,
                                             "apple_user_activity_content_id" : contentIdentifier])
            }

        }
    }
    
    @objc public func removeUserActivity() {
        DispatchQueue.main.async {
            //get current RN view controller
            guard let currentViewController = RCTPresentedViewController() else {
                return
            }
            
            if let contentIdentifier = currentViewController.userActivity?.externalMediaContentIdentifier,
               let activityType = currentViewController.userActivity?.activityType {
                self.logger?.debugLog(message: "Removing userActivity from dismissed show screen",
                                      data: ["activityType": activityType,
                                             "apple_user_activity_content_id" : contentIdentifier])
            }

            //set and activate user activity
            currentViewController.userActivity?.invalidate()
        }
    }
}

extension Bundle {
    func hasActivity(for type: String) -> Bool {
        guard let activities = infoDictionary?["NSUserActivityTypes"] as? [String] else {
            return false
        }
        return activities.first { $0 == type } != nil ? true : false
    }
}
