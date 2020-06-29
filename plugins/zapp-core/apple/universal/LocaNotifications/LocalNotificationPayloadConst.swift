//
//  LocalNotificationPayloadConst.swift
//  ZappApple
//
//  Created by Anton Kononenko on 3/12/20.
//

import Foundation
/*
 Local notification payload example
 {
    identifier:String,
    title: String,
    body: String,
    unixTimestamp: Double,
    actions:[
        {
            identifier: String,
            title: String,
            textInput: Bool,
            buttonType: String,
            url:String
        }
    ],
    attachments: [{
        image_uri: String,
        iosOverrideImageUri: String,
        androidOverrideImageUri: String,
    }]
 }
 */

public extension Notification.Name {
    static let kLocalNotificationRecievedNotification = Notification.Name("LOCAL_NOTIFICATION_RECIEVED_NOTIFICATION")
}

public struct LocalNotificationPayloadConst {
    /// Uniquie identifier of the local notification
    public static let identifier = "identifier"

    /// Title of the local notification
    public static let title = "title"

    /// Body of the local notification
    public static let body = "body"

    /// Defines unix timestamp date when local notification will be fired
    public static let unixTimestamp = "unixTimestamp"

    /// Dictionary of the buttons provided for local notification, use `dismiss` to select distuctive red button
    public static let actions = "actions"

    /// Dictionary of the avail atachments for the local notification
    public static let attachments = "attachments"
    
    /// Url of the default action
    public static let defaultActionUrl = "defaultActionUrl"
    
    /// Url of the dismiss action
    public static let dismissActionUrl = "dismissActionUrl"
}

public struct LocalNotificationPayloadActions {
    /// Uniquie identifier of the local notification
    public static let identifier = "identifier"

    /// Title of the local notification
    public static let title = "title"

    /// Button type for action buttons
    public static let buttonType = "buttonType"

    /// Attached URL
    public static let url = "url"
    
    public struct ButtonType {
        /// Whether this action should be indicated as destructive.
        public static let danger = "danger"

        /// Regular button
        public static let `default` = "default"
    }
}

public struct LocalNotificationPayloadAttachments {
    /// Uri of the attachments file
    public static let imageUri = "imageUri"
    
    /// Uri of the ios attachments file
    public static let iosOverrideImageUri = "iosOverrideImageUri"
    
}
