//
//  UNNotificationTrigger+Payload.swift
//  ZappLocalNotifications
//
//  Created by Anton Kononenko on 3/12/20.
//

import Foundation
import ZappCore

extension UNNotificationTrigger {
    /// Minimal trigger allowed to fire
    static let kMinimumTriggerTimeInterval:TimeInterval = 1

    /// Cretate Trigger for local notification by payload dictionary
    /// - Parameter payload: Dictionary that contains data for creation Local Notification
    class func trigger(payload: [AnyHashable: Any]) -> UNNotificationTrigger? {
        if let unixTimestamp = retrieveUnixTimeStamp(payload: payload) {
            let date = Date(timeIntervalSince1970: TimeInterval(unixTimestamp))
            let timeInterval = date.timeIntervalSinceNow
            return timeInterval > 0 ? UNTimeIntervalNotificationTrigger(timeInterval: timeInterval,
                                                                        repeats: false) : nil
        } else {
            return UNTimeIntervalNotificationTrigger(timeInterval: kMinimumTriggerTimeInterval,
                                                     repeats: false)
        }
    }

    /// Retrieves unix timestamp from payload
    /// - Parameter payload: Dictionary that contains data for creation Local Notification
    class func retrieveUnixTimeStamp(payload: [AnyHashable: Any]) -> Double? {
        if let retVal = payload[LocalNotificationPayloadConst.unixTimestamp] as? NSNumber {
            return retVal.doubleValue
        } else if let timestampString = payload[LocalNotificationPayloadConst.unixTimestamp] as? String,
            let retVal = Double(timestampString) {
            return retVal
        }
        return nil
    }
}
