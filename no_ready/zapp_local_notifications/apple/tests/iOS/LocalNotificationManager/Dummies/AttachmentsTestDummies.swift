//
//  AttachmentsTestDummies.swift
//  ZappLocalNotifications
//
//  Created by Anton Kononenko on 3/18/20.
//

import Foundation
import ZappCore

let payload_empty: [AnyHashable: Any] = [:]
let payload_attachmetns = [LocalNotificationPayloadConst.attachments: [[LocalNotificationPayloadAttachments.imageUri: "baran.png"]]]
let payload_attachmetns_empty_array = [LocalNotificationPayloadConst.attachments: []]
let payload_attachmetns_wrong_array = [1: [[LocalNotificationPayloadAttachments.imageUri: "baran.png"]]]
let payload_attachmetns_two_items = [LocalNotificationPayloadConst.attachments: [[LocalNotificationPayloadAttachments.imageUri: "baran.png"],
                                                                                 [LocalNotificationPayloadAttachments.imageUri: "baran2.png"]]]

let attachmetns_dummy_empty: [[AnyHashable: String]] = []

let attachmetns_dummy: [[AnyHashable: String]] = [[LocalNotificationPayloadAttachments.imageUri: "baran.png"]]

let attachmetns_dummy_two_items: [[AnyHashable: String]] = [
    [LocalNotificationPayloadAttachments.imageUri: "baran.png"],
    [LocalNotificationPayloadAttachments.imageUri: "baran2.png"],
]

let attachmetns_dummy_firstCorrupted: [[AnyHashable: String]] = [
    [LocalNotificationPayloadAttachments.imageUri: "some.png"],
    [LocalNotificationPayloadAttachments.imageUri: "baran2.png"],
]

let dict_dummy_empty: [AnyHashable: String] = [:]

let dict_dummy: [AnyHashable: String] = [LocalNotificationPayloadAttachments.imageUri: "baran.png"]

let dict_dummy_two_images: [AnyHashable: String] = [LocalNotificationPayloadAttachments.imageUri: "baran.png",
                                                    LocalNotificationPayloadAttachments.iosOverrideImageUri: "baran2.png"]

let dict_dummy_image_uri_empty: [AnyHashable: String] = [LocalNotificationPayloadAttachments.iosOverrideImageUri: "baran2.png"]

let dict_dummy_image_uri_ios_empty: [AnyHashable: String] = [LocalNotificationPayloadAttachments.imageUri: "baran.png"]
