//
//  UNNotificationAttachment+Payload.swift
//  ZappLocalNotifications
//
//  Created by Anton Kononenko on 3/16/20.
//

import Foundation
import ZappCore

/// Retrieve recources bundle, was make to able override bundle in test cases
var UNNotificationAttachmentResourceBundle = Bundle.main

extension UNNotificationAttachment {
    /// Create attachments array by payload dictionary
    /// - Parameter payload: Dictionary that contains data for creation Local Notification
    class func attachments(payload: [AnyHashable: Any]) -> [UNNotificationAttachment] {
        var retVal: [UNNotificationAttachment] = []
        guard let attachments = attachmentsFromPayload(payload: payload) else {
            return retVal
        }
        if let attachment = attachmentItem(attachments: attachments) {
            retVal = [attachment]
        }
        return retVal
    }

    /// Rretrieve attachments from payload
    /// - Parameter payload: Dictionary payload to create local notification
    class func attachmentsFromPayload(payload: [AnyHashable: Any]) -> [[AnyHashable: String]]? {
        guard let retVal = payload[LocalNotificationPayloadConst.attachments] as? [[AnyHashable: String]],
            retVal.isEmpty == false else {
            return nil
        }
        return retVal
    }

    /// Create attachment item
    /// - Parameter attachments: Dictionary that represents attachments objects from payload
    class func attachmentItem(attachments: [[AnyHashable: String]]) -> UNNotificationAttachment? {
        var retVal: UNNotificationAttachment?
        for attachment in attachments {
            if let url = urlForAttachment(attachment: attachment),
                let attachment = try? UNNotificationAttachment(identifier: url.path,
                                                               url: url,
                                                               options: .none) {
                retVal = attachment

                // Limit 1 availible attachment
                break
            }
        }
        return retVal
    }

    /// Retrieve URL by attachment dictionary from options
    /// - Parameter attachment: Dictionary that represents attachments objects from payload
    class func urlForAttachment(attachment: [AnyHashable: String]) -> URL? {
        if let url = urlForAttachmentFromKey(attachment: attachment,
                                             key: LocalNotificationPayloadAttachments.iosOverrideImageUri) {
            return url
        } else if let url = urlForAttachmentFromKey(attachment: attachment,
                                                    key: LocalNotificationPayloadAttachments.imageUri) {
            return url
        }

        return nil
    }

    /// Retrieve URL by attachment dictionary for specific key
    /// - Parameters:
    ///   - attachment: Dictionary that represents attachments objects from payload
    ///   - key: key to search item
    class func urlForAttachmentFromKey(attachment: [AnyHashable: String],
                                       key: String) -> URL? {
        if let fileName = attachment[key],
            let url = urlFromUri(uri: fileName) {
            return url
        }
        return nil
    }

    /// Create url by URI object
    /// - Parameter uri: file name of the expected item
    class func urlFromUri(uri: String) -> URL? {
        let fileNameNoWhiteSpaces = uri.replacingOccurrences(of: " ", with: "")
        if let url = UNNotificationAttachmentResourceBundle.url(forResource: fileNameNoWhiteSpaces,
                                                                withExtension: ""),
            FileManager().fileExists(atPath: url.path) {
            return url
        }
        return nil
    }
}
