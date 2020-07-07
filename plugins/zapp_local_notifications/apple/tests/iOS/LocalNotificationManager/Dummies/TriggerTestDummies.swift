//
//  TriggerTestDummies.swift
//  ZappLocalNotifications
//
//  Created by Anton Kononenko on 3/18/20.
//

import Foundation
import ZappCore

let trigger_no_timestamp: [AnyHashable: Any] = [:]

let trigger_timestamp: [AnyHashable: Any] = [
    LocalNotificationPayloadConst.unixTimestamp: 32503726800,
]

let trigger_timestamp_double: [AnyHashable: Any] = [
    LocalNotificationPayloadConst.unixTimestamp: 32503726800.33,
]

let trigger_timestamp_string: [AnyHashable: Any] = [
    LocalNotificationPayloadConst.unixTimestamp: "32503726800",
]

let trigger_timestamp_corrupted: [AnyHashable: Any] = [
    LocalNotificationPayloadConst.unixTimestamp: "A1b7-test",
]

let trigger_timestamp_old: [AnyHashable: Any] = [
    LocalNotificationPayloadConst.unixTimestamp: 946731600,
]
