//
//  PushProviderProtocol.swift
//  ZappCore
//
//  Created by Anton Kononenko on 1/23/20.
//  Copyright © 2020 Applicaster LTD. All rights reserved.
//

import Foundation

@objc public protocol PushProviderProtocol: PluginAdapterProtocol {
    /**
     add tags to device
     */
    @objc optional func addTagsToDevice(_ tags: [String]?,
                                        completion: @escaping (_ success: Bool, _ tags: [String]?) -> Void)

    /**
     remove tags from device
     */
    @objc optional func removeTagsToDevice(_ tags: [String]?,
                                           completion: @escaping (_ success: Bool, _ tags: [String]?) -> Void)

    /**
     get device's tag list
     */
    @objc optional func getDeviceTags() -> [String]?
    
    /**
     register Token with push server.
     */
    @objc optional func didRegisterForRemoteNotificationsWithDeviceToken(_ deviceToken: Data)

    /**
     register userNotificationSettings with push server
     */
    @objc optional func didRegisterUserNotificationSettings(_ notificationSettings: UNNotificationSettings)
}
