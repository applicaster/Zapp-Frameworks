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

class UNNotificationCategoryPayloadTests: XCTestCase {
    func isButtonDestructive() {
        var result = UNNotificationCategory.isButtonDestructive(actionButtonData: action_is_button_destructive_empty)
        XCTAssertFalse(result)

        result = UNNotificationCategory.isButtonDestructive(actionButtonData: action_is_button_destructive_data)
        XCTAssertTrue(result)

        result = UNNotificationCategory.isButtonDestructive(actionButtonData: action_is_button_destructive_wrong_data)
        XCTAssertFalse(result)

        result = UNNotificationCategory.isButtonDestructive(actionButtonData: action_is_button_destructive_data_default)
        XCTAssertFalse(result)
    }

    func testActionFromActionButtonData() {
        var result = UNNotificationCategory.actionFromActionButtonData(actionButtonData: action_button_data_empty)
        XCTAssertNil(result)

        result = UNNotificationCategory.actionFromActionButtonData(actionButtonData: action_button_data)
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.options.contains(.authenticationRequired) ?? false)
        XCTAssertTrue(result?.options.contains(.foreground) ?? false)

        result = UNNotificationCategory.actionFromActionButtonData(actionButtonData: action_button_data_no_title)
        XCTAssertNil(result)

        result = UNNotificationCategory.actionFromActionButtonData(actionButtonData: action_button_data_no_identifier)
        XCTAssertNil(result)

        result = UNNotificationCategory.actionFromActionButtonData(actionButtonData: action_button_data_corrupted_data)
        XCTAssertNil(result)

        result = UNNotificationCategory.actionFromActionButtonData(actionButtonData: action_button_data_title_number)
        XCTAssertNil(result)

        result = UNNotificationCategory.actionFromActionButtonData(actionButtonData: action_button_data_identifier_number)
        XCTAssertNil(result)

        result = UNNotificationCategory.actionFromActionButtonData(actionButtonData: action_button_data_destructive)
        XCTAssertTrue(result?.options.contains(.destructive) ?? false)
        XCTAssertTrue(result?.options.contains(.authenticationRequired) ?? false)
        XCTAssertTrue(result?.options.contains(.foreground) ?? false)
    }

    func testActionsButtonForCategory() {
        var result = UNNotificationCategory.actionsButtonForCategory(actions: actions_button_for_category_empty)
        XCTAssertTrue(result.actionsButton.count == 0)
        XCTAssertTrue(result.categoryIdentifier == UNNotificationCategory.baseCategoryIdentifier)

        result = UNNotificationCategory.actionsButtonForCategory(actions: actions_button_for_category)
        XCTAssertTrue(result.actionsButton.count == 2)
        XCTAssertTrue(result.categoryIdentifier == "\(UNNotificationCategory.baseCategoryIdentifier)-id_1-id_2")

        result = UNNotificationCategory.actionsButtonForCategory(actions: actions_button_for_category_first_corrupted)
        XCTAssertTrue(result.actionsButton.count == 1)
        XCTAssertTrue(result.categoryIdentifier == "\(UNNotificationCategory.baseCategoryIdentifier)-id_2")

        result = UNNotificationCategory.actionsButtonForCategory(actions: actions_button_for_category_same_id)
        XCTAssertTrue(result.actionsButton.count == 1)
        XCTAssertTrue(result.categoryIdentifier == "\(UNNotificationCategory.baseCategoryIdentifier)-id_1")
    }

    func actionsButtonsFromPayloadx() {
        var result = UNNotificationCategory.actionsButtonsFromPayload(payload: actions_button_from_payload_data_empty)
        XCTAssertNil(result)

        result = UNNotificationCategory.actionsButtonsFromPayload(payload: actions_button_from_payload_data)
        XCTAssertNotNil(result)

        result = UNNotificationCategory.actionsButtonsFromPayload(payload: actions_button_from_payload_data_corrupted)
        XCTAssertNil(result)
    }

    func testCategory() {
        var result = UNNotificationCategory.category(payload: category_data_empty)
        XCTAssertNil(result)

        result = UNNotificationCategory.category(payload: category_data)
        XCTAssertTrue(result?.identifier == "\(UNNotificationCategory.baseCategoryIdentifier)-id_1-id_2")
        XCTAssertTrue(result?.actions.count == 2)

        result = UNNotificationCategory.category(payload: category_data_corrupted)
        XCTAssertTrue(result?.identifier == "\(UNNotificationCategory.baseCategoryIdentifier)-id_1")
        XCTAssertTrue(result?.actions.count == 1)

        result = UNNotificationCategory.category(payload: category_data_wrong_structure)
        XCTAssertNil(result)
    }
}

