//
//  LocalStorageTests.swift
//  ZappiOSTests
//
//  Created by Alex Zchut on 14/03/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import XCTest
@testable import ZappApple
import ZappCore

class LocalStorageTests: XCTestCase {
    struct Constants {
        static let key = "LocalStorageTests.key"
        static let value = "LocalStorageTests.value"
        static let namespace = "LocalStorageTests.namespace"
    }

    enum LocalStorageError: Error, Equatable {
        case unableToSetValueForKey
        case unableToGetValueForKey
        case unableToRemoveValueForKey
    }

    struct ErrorMessages {
        static let getValueNotMatch = "[LocalStorage - Get] - Value is not equal to `\(Constants.value)`"
        static let removeValuePersist = "[LocalStorage - Remove] - Value exists after removal"
    }

    override func setUpWithError() throws {
        guard LocalStorage.sharedInstance.set(key: Constants.key,
                                              value: Constants.value,
                                              namespace: Constants.namespace) == true else {
            throw LocalStorageError.unableToSetValueForKey
        }
    }

    func testGetValue() throws {
        guard let value = getValue(for: Constants.key,
                                   namespace: Constants.namespace) else {
            throw LocalStorageError.unableToGetValueForKey
        }

        XCTAssertEqual(value, Constants.value, ErrorMessages.getValueNotMatch)
    }

    func testRemoveValue() throws {
        guard LocalStorage.sharedInstance.removeItem(key: Constants.key,
                                                     namespace: Constants.namespace) == true else {
            throw LocalStorageError.unableToRemoveValueForKey
        }

        let value = getValue(for: Constants.key, namespace: Constants.namespace)

        XCTAssertNil(value, ErrorMessages.removeValuePersist)
    }

    func getValue(for key: String, namespace: String?) -> String? {
        return LocalStorage.sharedInstance.get(key: key,
                                               namespace: namespace)
    }
}
