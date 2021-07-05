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

public enum PushProviderError: Error, CustomStringConvertible {
    case failedToRemoveTags0NotRegisteredForRemoteNotifications
    case failedToRemoveTags0NoTagsToRemove
    case failedToRemoveTags0NoPushProvidersAvailable
    
    case failedToAddTags0NotRegisteredForRemoteNotifications
    case failedToAddTags0NoTagsToRegister
    case failedToAddTags0NoPushProvidersAvailable

    public var description: String {
        var format = ""
        switch self {
        case .failedToRemoveTags0NotRegisteredForRemoteNotifications:
            format = NSLocalizedString("Failed to remove tags. Not registered for remote notifications", comment: "")
        case .failedToRemoveTags0NoTagsToRemove:
            format = NSLocalizedString("Failed to remove tags. Tags array appears empty, no tags to remove", comment: "")
        case .failedToRemoveTags0NoPushProvidersAvailable:
            format = NSLocalizedString("Failed to remove tags. No push providers attached to the app", comment: "")
        case .failedToAddTags0NotRegisteredForRemoteNotifications:
            format = NSLocalizedString("Failed to add tags. Not registered for remote notifications", comment: "")
        case .failedToAddTags0NoTagsToRegister:
            format = NSLocalizedString("Failed to add tags. Tags array appears empty, no tags to add", comment: "")
        case .failedToAddTags0NoPushProvidersAvailable:
            format = NSLocalizedString("Failed to add tags. No push providers attached to the app", comment: "")
        }
        
        return String.localizedStringWithFormat(format)
    }
    
    var errorDescription: String? {
            get {
                return self.description
            }
        }
}
