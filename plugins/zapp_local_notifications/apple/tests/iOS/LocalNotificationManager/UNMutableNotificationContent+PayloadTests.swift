//
//  UNMutableNotificationContent+PayloadTests.swift
//  ZappLocalNotifications
//
//  Created by Anton Kononenko on 1/9/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation
import XCTest
@testable import ZappLocalNotifications

class UNMutableNotificationContentPayloadTests: XCTestCase {
    func testContent() {
        let content: UNMutableNotificationContent = UNMutableNotificationContent(payload: content_dummy)
        XCTAssertTrue(content.title == "Title")
        XCTAssertTrue(content.body == "Body")
        XCTAssertTrue(content.badge == 1)
        XCTAssertTrue(content.userInfo.keys.count == 2)
        XCTAssertTrue(content.sound == UNNotificationSound.default)
    }

    func testContentHeadlinedKeys() {
        let content: UNMutableNotificationContent = UNMutableNotificationContent(payload: content_dummy_headlined_keys)
        XCTAssertTrue(content.title == "")
        XCTAssertTrue(content.body == "")
        XCTAssertTrue(content.badge == 1)
        XCTAssertTrue(content.userInfo.keys.count == 2)
        XCTAssertTrue(content.sound == UNNotificationSound.default)
    }

    func testContentNoData() {
        let content: UNMutableNotificationContent = UNMutableNotificationContent(payload: content_dummy_no_data)
        XCTAssertTrue(content.title == "")
        XCTAssertTrue(content.body == "")
        XCTAssertTrue(content.badge == 1)
        XCTAssertTrue(content.sound == UNNotificationSound.default)
    }

    func testContentNoDataString() {
        let content: UNMutableNotificationContent = UNMutableNotificationContent(payload: content_dummy_no_data_string)
        XCTAssertTrue(content.title == "")
        XCTAssertTrue(content.body == "")
        XCTAssertTrue(content.badge == 1)
        XCTAssertTrue(content.userInfo.keys.count == 2)
        XCTAssertTrue(content.sound == UNNotificationSound.default)
    }

    func testContentNumber() {
        let content: UNMutableNotificationContent = UNMutableNotificationContent(payload: content_dummy_no_data_string)
        XCTAssertTrue(content.title == "")
        XCTAssertTrue(content.body == "")
        XCTAssertTrue(content.userInfo.keys.count == 2)
        XCTAssertTrue(content.badge == 1)
        XCTAssertTrue(content.sound == UNNotificationSound.default)
    }

    func testContentBool() {
        let content: UNMutableNotificationContent = UNMutableNotificationContent(payload: content_dummy_no_data_string)
        XCTAssertTrue(content.title == "")
        XCTAssertTrue(content.body == "")
        XCTAssertTrue(content.userInfo.keys.count == 2)
        XCTAssertTrue(content.badge == 1)
        XCTAssertTrue(content.sound == UNNotificationSound.default)
    }
}

