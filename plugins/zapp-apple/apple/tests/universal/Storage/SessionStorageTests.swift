//
//  SessionStorageTests.swift
//  ZappiOSTests
//
//  Created by Alex Zchut on 14/03/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import XCTest
@testable import ZappApple
import ZappCore

class SessionStorageTests: XCTestCase {
    struct Constants {
        static let key = "SessionStorageTests.key"
        static let value = "SessionStorageTests.value"
        static let namespace = "SessionStorageTests.namespace"
    }

    enum SessionStorageError: Error, Equatable {
        case unableToSetValueForKey
        case unableToGetValueForKey
        case unableToRemoveValueForKey
    }

    struct ErrorMessages {
        static let getValueNotMatch = "[SessionStorage - Get] - Value is not equal to `\(Constants.value)`"
        static let removeValuePersist = "[SessionStorage - remove] - Value exists after removal"
    }

    override func setUpWithError() throws {
        guard SessionStorage.sharedInstance.set(key: Constants.key,
                                                value: Constants.value,
                                                namespace: Constants.namespace) == true else {
            throw SessionStorageError.unableToSetValueForKey
        }
    }

    func testGetValue() throws {
        guard let value = getValue(for: Constants.key,
                                   namespace: Constants.namespace) else {
            throw SessionStorageError.unableToGetValueForKey
        }

        XCTAssertEqual(value, Constants.value, ErrorMessages.getValueNotMatch)
    }

    func testRemoveValue() throws {
        guard SessionStorage.sharedInstance.removeItem(key: Constants.key,
                                                       namespace: Constants.namespace) == true else {
            throw SessionStorageError.unableToRemoveValueForKey
        }

        let value = getValue(for: Constants.key, namespace: Constants.namespace)

        XCTAssertNil(value, ErrorMessages.removeValuePersist)
    }

    func getValue(for key: String, namespace: String?) -> String? {
        return SessionStorage.sharedInstance.get(key: key,
                                                 namespace: namespace)
    }
}
