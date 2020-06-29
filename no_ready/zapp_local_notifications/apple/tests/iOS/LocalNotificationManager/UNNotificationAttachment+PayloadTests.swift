//
// UNNotificationAttachment+PayloadTests.swift
//  ZappLocalNotifications
//
//  Created by Anton Kononenko on 1/9/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation
import XCTest
@testable import ZappLocalNotifications
import ZappCore

class UNNotificationAttachmentPayloadTests: XCTestCase {
    override func setUp() {
        UNNotificationAttachmentResourceBundle = Bundle(for: ZappLocalNotifications.self)
    }

    func testUrlFromUri() {
        var result = UNNotificationAttachment.urlFromUri(uri: "baran.png")
        XCTAssertNotNil(result)

        result = UNNotificationAttachment.urlFromUri(uri: "  ba ran. p n g")
        XCTAssertNotNil(result)

        result = UNNotificationAttachment.urlFromUri(uri: "baran")
        XCTAssertNil(result)

        result = UNNotificationAttachment.urlFromUri(uri: "")
        XCTAssertNil(result)

        result = UNNotificationAttachment.urlFromUri(uri: "233144433")
        XCTAssertNil(result)
    }

    func testUrlForAttachmentFromKey() {
        var result = UNNotificationAttachment.urlForAttachmentFromKey(attachment: dict_dummy_empty,
                                                                      key: LocalNotificationPayloadAttachments.imageUri)
        XCTAssertNil(result)

        result = UNNotificationAttachment.urlForAttachmentFromKey(attachment: dict_dummy,
                                                                  key: LocalNotificationPayloadAttachments.imageUri)
        XCTAssertNotNil(result)
    }

    func testUrlForAttachment() {
        var result = UNNotificationAttachment.urlForAttachment(attachment: dict_dummy_empty)
        XCTAssertNil(result)

        result = UNNotificationAttachment.urlForAttachment(attachment: dict_dummy_two_images)
        XCTAssertTrue(result?.path.hasSuffix("baran2.png") ?? false)

        result = UNNotificationAttachment.urlForAttachment(attachment: dict_dummy_image_uri_empty)
        XCTAssertTrue(result?.path.hasSuffix("baran2.png") ?? false)

        result = UNNotificationAttachment.urlForAttachment(attachment: dict_dummy_image_uri_ios_empty)
        XCTAssertTrue(result?.path.hasSuffix("baran.png") ?? false)
    }

    func testAttachmentItem() {
        var result = UNNotificationAttachment.attachmentItem(attachments: attachmetns_dummy_empty)
        XCTAssertNil(result)

        result = UNNotificationAttachment.attachmentItem(attachments: attachmetns_dummy)
        XCTAssertNotNil(result)

        result = UNNotificationAttachment.attachmentItem(attachments: attachmetns_dummy_two_items)
        XCTAssertTrue(result?.url.path.hasSuffix("baran.png") ?? false)

        result = UNNotificationAttachment.attachmentItem(attachments: attachmetns_dummy_firstCorrupted)
        XCTAssertTrue(result?.url.path.hasSuffix("baran2.png") ?? false)
    }

    func testAttachmentsFromPayload() {
        var result = UNNotificationAttachment.attachmentsFromPayload(payload: payload_empty)
        XCTAssertNil(result)

        result = UNNotificationAttachment.attachmentsFromPayload(payload: payload_attachmetns)
        XCTAssertNotNil(result)

        result = UNNotificationAttachment.attachmentsFromPayload(payload: payload_attachmetns_empty_array)
        XCTAssertNil(result)

        result = UNNotificationAttachment.attachmentsFromPayload(payload: payload_attachmetns_wrong_array)
        XCTAssertNil(result)
    }

    func testAttachments() {
        var result = UNNotificationAttachment.attachments(payload: payload_empty)
        XCTAssertTrue(result.count == 0)

         result = UNNotificationAttachment.attachments(payload: payload_attachmetns)
        XCTAssertTrue(result.count == 1)
        
        result = UNNotificationAttachment.attachments(payload: payload_attachmetns_two_items)
        XCTAssertTrue(result.count == 1)
    }
}

