//
//  UNNotificationTrigger+PayloadTests.swift
//  ZappLocalNotifications
//
//  Created by Anton Kononenko on 1/9/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation
import XCTest
@testable import ZappLocalNotifications

class UNNotificationTriggerPayloadTests: XCTestCase {
    func testNoTimestamp() {
        let triger: UNTimeIntervalNotificationTrigger = UNNotificationTrigger.trigger(payload: trigger_no_timestamp) as! UNTimeIntervalNotificationTrigger
        XCTAssertTrue(triger.timeInterval == 1)
    }
    
    func testTimestamp() {
        let triger: UNTimeIntervalNotificationTrigger = UNNotificationTrigger.trigger(payload: trigger_timestamp) as! UNTimeIntervalNotificationTrigger
        XCTAssertTrue(triger.timeInterval > 1)
    }
    
    func testTimestampDouble() {
         let triger: UNTimeIntervalNotificationTrigger = UNNotificationTrigger.trigger(payload: trigger_timestamp_double) as! UNTimeIntervalNotificationTrigger
         XCTAssertTrue(triger.timeInterval > 1)
     }
    
    func testTimestampString() {
        let triger: UNTimeIntervalNotificationTrigger = UNNotificationTrigger.trigger(payload: trigger_timestamp_string) as! UNTimeIntervalNotificationTrigger
        XCTAssertTrue(triger.timeInterval > 1)
    }
    
    func testTimestampCorrupted() {
        let triger: UNTimeIntervalNotificationTrigger = UNNotificationTrigger.trigger(payload: trigger_timestamp_corrupted) as! UNTimeIntervalNotificationTrigger
        XCTAssertTrue(triger.timeInterval == 1)
    }
    
    func testTimestampOldDate() {
        let triger = UNNotificationTrigger.trigger(payload: trigger_timestamp_old)
        XCTAssertNil(triger)
    }
}
