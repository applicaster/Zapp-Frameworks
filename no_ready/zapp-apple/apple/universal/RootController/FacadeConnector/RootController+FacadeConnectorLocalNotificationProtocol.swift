//
//  RootController+FacadeConnectorLocalNotificationProtocol.swift
//  ZappApple
//
//  Created by Anton Kononenko on 3/13/20.
//

import Foundation
import ZappCore

extension RootController: FacadeConnectorLocalNotificationProtocol {
    var errorDomainNoPluginExist: String {
        return "LOCAL_NOTIFICATION_PLUGIN_NOT_EXISTS"
    }

    public func cancelLocalNotifications(_ identifiers: [String]?,
                                         completion: @escaping (Bool, Error?) -> Void) {
        guard let localNotificationManager = pluginsManager.localNotificationManager else {
            completion(false, NSError(domain: errorDomainNoPluginExist,
                                      code: 0,
                                      userInfo: nil))
            return
        }
        localNotificationManager.cancelLocalNotifications(identifiers,
                                                          completion: completion)
    }

    public func presentLocalNotification(_ payload: [AnyHashable: Any],
                                         completion: @escaping (Bool, Error?) -> Void) {
        guard let localNotificationManager = pluginsManager.localNotificationManager else {
            completion(false, NSError(domain: errorDomainNoPluginExist,
                                      code: 0,
                                      userInfo: nil))
            return
        }
        localNotificationManager.presentLocalNotification(payload,
                                                          completion: completion)
    }
}
