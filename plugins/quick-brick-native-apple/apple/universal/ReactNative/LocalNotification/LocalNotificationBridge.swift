//
//  PluginsManager.swift
//  QuickBrickApple
//
//  Created by Anton Kononenko on 1/27/20.
//

import Foundation
import React
import ZappCore

@objc(LocalNotificationBridge)
class LocalNotificationBridge: NSObject, RCTBridgeModule {
    let kModuleName = "LocalNotificationBridge"
    let LocalNotificationRecievedEvent = "localNotificationReceived"
    let kErrorCodeFailedToScheduleLocalNotification = "FAILED_TO_SCHEDULE_LOCAL_NOTIFICATION"
    let kErrorCodeFailedToCancelLocalNotifications = "FAILED_TO_CANCEL_LOCAL_NOTIFICATION"

    static func moduleName() -> String! {
        return "LocalNotificationBridge"
    }

    static func requiresMainQueueSetup() -> Bool {
        true
    }

    @objc func cancelLocalNotifications(_ identifiers: [String]?,
                                        resolver: @escaping RCTPromiseResolveBlock,
                                        rejecter: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            guard let identifiers = identifiers else {
                rejecter(self.kErrorCodeFailedToCancelLocalNotifications,
                         nil,
                         nil)
                return
            }

            FacadeConnector.connector?.localNotification?.cancelLocalNotifications(identifiers,
                                                                                   completion: { success, error in
                                                                                       success && error == nil ? resolver(success) :
                                                                                           rejecter(self.kErrorCodeFailedToCancelLocalNotifications,
                                                                                                    nil,
                                                                                                    error)
            })
        }
    }

    @objc public func presentLocalNotification(_ payload: [AnyHashable: Any]?,
                                               resolver: @escaping RCTPromiseResolveBlock,
                                               rejecter: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            guard let payload = payload as [AnyHashable: Any]? else {
                return
            }

            FacadeConnector.connector?.localNotification?.presentLocalNotification(payload,
                                                                                   completion: { isScheduled, error in
                                                                                       isScheduled && error == nil ? resolver(isScheduled) :
                                                                                           rejecter(self.kErrorCodeFailedToScheduleLocalNotification,
                                                                                                    nil,
                                                                                                    error)
            })
        }
    }
}
