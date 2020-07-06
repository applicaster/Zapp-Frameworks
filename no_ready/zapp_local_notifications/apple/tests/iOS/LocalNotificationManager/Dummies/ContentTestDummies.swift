//
//  ContentTestDummies.swift
//  ZappLocalNotifications
//
//  Created by Anton Kononenko on 3/18/20.
//

import Foundation
import ZappCore

let content_dummy: [AnyHashable: Any] = [
    LocalNotificationPayloadConst.title: "Title",
    LocalNotificationPayloadConst.body: "Body",
]

let content_dummy_headlined_keys: [AnyHashable: Any] = [
    "Title": "Title",
    "Body": "Body",
]

let content_dummy_no_data: [AnyHashable: Any] = [:]

let content_dummy_no_data_string: [AnyHashable: Any] = [
    LocalNotificationPayloadConst.title: "",
    LocalNotificationPayloadConst.body: "",
]

let content_dummy_numers: [AnyHashable: Any] = [
    LocalNotificationPayloadConst.title: 12345,
    LocalNotificationPayloadConst.body: 12345,
]

let content_dummy_bool: [AnyHashable: Any] = [
    LocalNotificationPayloadConst.title: true,
    LocalNotificationPayloadConst.body: true,
]
