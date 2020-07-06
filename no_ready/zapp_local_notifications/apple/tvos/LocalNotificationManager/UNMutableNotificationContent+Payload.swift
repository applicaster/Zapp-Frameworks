//
//  UNMutableNotificationContent+Payload.swift
//  ZappLocalNotifications
//
//  Created by Anton Kononenko on 3/11/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation
import UserNotifications
import ZappCore

extension UNMutableNotificationContent {
    convenience init(payload: [AnyHashable: Any]) {
        self.init()
        badge = 1
    }
}
