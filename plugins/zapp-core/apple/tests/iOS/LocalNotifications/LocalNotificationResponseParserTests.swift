//
//  LocalNotificationResponseParserTests.swift
//  ZappCore
//
//  Created by Anton Kononenko on 1/9/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation
import XCTest
@testable import ZappCore

class LocalNotificationResponseParserTests: XCTestCase {
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUrlFromAction() {
        let correctIdentifier = "id_1"
        let wrongIdentifier = "id_2"

        var result = LocalNotificationResponseParser.urlFromAction(actionData: url_from_action_data,
                                                                   actionIdentifier: correctIdentifier)
        XCTAssertNotNil(result)

        result = LocalNotificationResponseParser.urlFromAction(actionData: url_from_action_data,
                                                               actionIdentifier: wrongIdentifier)
        XCTAssertNil(result)

        result = LocalNotificationResponseParser.urlFromAction(actionData: url_from_action_data_url_empty,
                                                               actionIdentifier: wrongIdentifier)
        XCTAssertNil(result)

        result = LocalNotificationResponseParser.urlFromAction(actionData: url_from_action_data_url_not_exist,
                                                               actionIdentifier: wrongIdentifier)
        XCTAssertNil(result)
    }

    func testActionsFromPayload() {
        var result = LocalNotificationResponseParser.actionsFromPayload(payload: actions_from_payload_empty)
        XCTAssertNil(result)

        result = LocalNotificationResponseParser.actionsFromPayload(payload: actions_from_payload_data)
        XCTAssertNotNil(result)

        result = LocalNotificationResponseParser.actionsFromPayload(payload: actions_from_payload_incorrect_not_array)
        XCTAssertNil(result)

        result = LocalNotificationResponseParser.actionsFromPayload(payload: actions_from_payload_data_not_dict)
        XCTAssertNil(result)

        result = LocalNotificationResponseParser.actionsFromPayload(payload: actions_from_payload_data_wrong_dict_type)
        XCTAssertNil(result)
    }

    func testFindUrlInActionsPayload() {
        let actionIdentifierOne = "id_1"
        let actionIdentifierTwo = "id_2"
        let actionIdentifierThree = "id_3"

        var result = LocalNotificationResponseParser.findUrlInActionsPayload(payload: actions_from_payload_empty,
                                                                             actionIdentifier: actionIdentifierOne)
        XCTAssertNil(result)

        result = LocalNotificationResponseParser.findUrlInActionsPayload(payload: actions_from_payload_empty,
                                                                         actionIdentifier: actionIdentifierTwo)
        XCTAssertNil(result)

        result = LocalNotificationResponseParser.findUrlInActionsPayload(payload: actions_from_payload_empty,
                                                                         actionIdentifier: actionIdentifierThree)
        XCTAssertNil(result)

        result = LocalNotificationResponseParser.findUrlInActionsPayload(payload: find_url_in_actions_payload_data_empty,
                                                                         actionIdentifier: actionIdentifierOne)
        XCTAssertNil(result)
    }

    func testUrlFromPayloadForDefaultKey() {
        let keyToSearchOne = LocalNotificationPayloadConst.dismissActionUrl
        let keyToSearchTwo = LocalNotificationPayloadConst.defaultActionUrl
        let keyToSearchThree = "some_not_existing_key"

        var result = LocalNotificationResponseParser.urlFromPayloadForDefaultKey(payload: url_from_payload_for_default_key_empty,
                                                                                 key: keyToSearchOne)
        XCTAssertNil(result)

        result = LocalNotificationResponseParser.urlFromPayloadForDefaultKey(payload: url_from_payload_for_default_key_data,
                                                                             key: keyToSearchOne)
        XCTAssertNotNil(result)

        result = LocalNotificationResponseParser.urlFromPayloadForDefaultKey(payload: url_from_payload_for_default_key_data,
                                                                             key: keyToSearchTwo)
        XCTAssertNotNil(result)

        result = LocalNotificationResponseParser.urlFromPayloadForDefaultKey(payload: url_from_payload_for_default_key_data,
                                                                             key: keyToSearchThree)
        XCTAssertNil(result)

        result = LocalNotificationResponseParser.urlFromPayloadForDefaultKey(payload: url_from_payload_for_default_key_not_wrong,
                                                                             key: keyToSearchTwo)
        XCTAssertNil(result)
    }

    func testDefaultActionKeyFromActionIdentifier() {
        let dismissAction = UNNotificationDismissActionIdentifier
        let defaultAction = UNNotificationDefaultActionIdentifier
        let notExistingAction = "not_existing_action"

        var result = LocalNotificationResponseParser.defaultActionKeyFromActionIdentifier(actionIdentifier: dismissAction)
        XCTAssertTrue(result == LocalNotificationPayloadConst.dismissActionUrl)

        result = LocalNotificationResponseParser.defaultActionKeyFromActionIdentifier(actionIdentifier: defaultAction)
        XCTAssertTrue(result == LocalNotificationPayloadConst.defaultActionUrl)

        result = LocalNotificationResponseParser.defaultActionKeyFromActionIdentifier(actionIdentifier: notExistingAction)
        XCTAssertNil(result)
    }

    func testFindUrlForDefaultActionsPayload() {
        let dismissAction = UNNotificationDismissActionIdentifier
        let defaultAction = UNNotificationDefaultActionIdentifier
        let notExistingAction = "not_existing_action"

        var result = LocalNotificationResponseParser.findUrlForDefaultActionsPayload(payload: url_from_payload_for_default_key_empty,
                                                                                     actionIdentifier: dismissAction)
        XCTAssertNil(result)

        result = LocalNotificationResponseParser.findUrlForDefaultActionsPayload(payload: url_from_payload_for_default_key_data,
                                                                                 actionIdentifier: dismissAction)
        XCTAssertNotNil(result)

        result = LocalNotificationResponseParser.findUrlForDefaultActionsPayload(payload: url_from_payload_for_default_key_data,
                                                                                 actionIdentifier: defaultAction)
        XCTAssertNotNil(result)

        result = LocalNotificationResponseParser.findUrlForDefaultActionsPayload(payload: url_from_payload_for_default_key_data,
                                                                                 actionIdentifier: notExistingAction)
        XCTAssertNil(result)

        result = LocalNotificationResponseParser.findUrlForDefaultActionsPayload(payload: url_from_payload_for_default_key_not_wrong,
                                                                                 actionIdentifier: defaultAction)
        XCTAssertNil(result)
    }
}

