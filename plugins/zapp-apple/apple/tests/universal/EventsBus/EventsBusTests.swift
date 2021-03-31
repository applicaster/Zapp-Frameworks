//
//  EventsBusTests.swift
//  ZappiOSTests
//
//  Created by Alex Zchut on 14/03/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import XCTest
@testable import ZappApple
import ZappCore

class EventsBusTests: XCTestCase {
    struct Constants {
        static let eventObject = "event"
        static let predefinedEventSource = "\(kNativeSubsystemPath)/PredefinedTypeTestEvent"
        static let predefinedEventSubject = "PredefinedType event subject"
        static let customEventType = "CustomEventType"
        static let customEventSource = "\(kNativeSubsystemPath)/CustomTypeTestEvent"
        static let customEventSubject = "CustomType event subject"
    }

    struct ErrorMessages {
        static let predefinedEventReceivedDataNil = "[PredefinedEvent] - Received Event `data` is nil"
        static let predefinedEventReceivedSourceNil = "[PredefinedEvent] - Received Event `source` is nil"
        static let predefinedEventReceivedSourceNotMatch = "[PredefinedEvent] - Received Event source is not equal to `\(Constants.predefinedEventSource)`"
        static let predefinedEventReceivedSubjectNil = "[PredefinedEvent] - Received Event `subject` is nil"
        static let predefinedEventReceivedSubjectNotMatch = "[PredefinedEvent] - Received Event subject is not equal to `\(Constants.predefinedEventSubject)`"

        static let customEventReceivedDataNil = "[CustomEvent] - Received Event `data` is nil"
        static let customEventReceivedSourceNil = "[CustomEvent] - Received Event `source` is nil"
        static let customEventReceivedSourceNotMatch = "[CustomEvent] - Received Event source is not equal to `\(Constants.customEventSource)`"
        static let customEventReceivedSubjectNil = "[CustomEvent] - Received Event `subject` is nil"
        static let customEventReceivedSubjectNotMatch = "[CustomEvent] - Received Event subject is not equal to `\(Constants.customEventSubject)`"
    }

    var receivedEventData: [AnyHashable: Any] = [:]
    var receivedEventSource: String = ""
    var receivedEventSubject: String = ""

    func testPredefinedEvent() {
        clearParams()
        EventsBus.subscribe(self,
                            type: EventsBusType(.testEvent),
                            handler: { content in
                                if let eventDetails = self.fetchEventDetails(from: content) {
                                    self.receivedEventData = eventDetails.data ?? [:]
                                    self.receivedEventSource = eventDetails.source ?? ""
                                    self.receivedEventSubject = eventDetails.subject ?? ""
                                }
                            })

        let event = EventsBus.Event(type: EventsBusType(.testEvent),
                                    source: Constants.predefinedEventSource,
                                    subject: Constants.predefinedEventSubject,
                                    data: [
                                        "name": "test",
                                        "parameters": [:],
                                    ])
        EventsBus.post(event)

        XCTAssertNotNil(receivedEventData, ErrorMessages.predefinedEventReceivedDataNil)
        XCTAssertNotNil(receivedEventSource, ErrorMessages.predefinedEventReceivedSourceNil)
        XCTAssertEqual(receivedEventSource, Constants.predefinedEventSource, ErrorMessages.predefinedEventReceivedSourceNotMatch)
        XCTAssertNotNil(receivedEventSubject, ErrorMessages.predefinedEventReceivedSubjectNil)
        XCTAssertEqual(receivedEventSubject, Constants.predefinedEventSubject, ErrorMessages.predefinedEventReceivedSubjectNotMatch)
    }

    func testCustomEvent() {
        clearParams()
        EventsBus.subscribe(self,
                            type: Constants.customEventType,
                            handler: { content in
                                if let eventDetails = self.fetchEventDetails(from: content) {
                                    self.receivedEventData = eventDetails.data ?? [:]
                                    self.receivedEventSource = eventDetails.source ?? ""
                                    self.receivedEventSubject = eventDetails.subject ?? ""
                                }
                            })

        let event = EventsBus.Event(type: Constants.customEventType,
                                    source: Constants.customEventSource,
                                    subject: Constants.customEventSubject,
                                    data: [
                                        "name": "test",
                                        "parameters": [:],
                                    ])
        EventsBus.post(event)

        XCTAssertNotNil(receivedEventData, ErrorMessages.customEventReceivedDataNil)
        XCTAssertNotNil(receivedEventSource, ErrorMessages.customEventReceivedSourceNil)
        XCTAssertEqual(receivedEventSource, Constants.customEventSource, ErrorMessages.customEventReceivedSourceNotMatch)
        XCTAssertNotNil(receivedEventSubject, ErrorMessages.customEventReceivedSubjectNil)
        XCTAssertEqual(receivedEventSubject, Constants.customEventSubject, ErrorMessages.customEventReceivedSubjectNotMatch)
    }

    func fetchEventDetails(from content: Notification?) -> EventsBus.Event? {
        return content?.userInfo?[Constants.eventObject] as? EventsBus.Event
    }

    func clearParams() {
        receivedEventData = [:]
        receivedEventSource = ""
        receivedEventSubject = ""
    }
}
