//
//  EventsBusTests.swift
//  ZappiOSTests
//
//  Created by Alex Zchut on 14/03/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import XCTest
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
    
    var receivedEventData: [AnyHashable: Any] = [:]
    var receivedEventSource: String = ""
    var receivedEventSubject: String = ""

    func testPostingPredefinedEvent() {
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
                                        "parameters": [:]
                                    ])
        EventsBus.post(event)
        
        XCTAssertNotNil(receivedEventData, "[PredefinedEvent] - Received Event `data` is nil")
        XCTAssertNotNil(receivedEventSource, "[PredefinedEvent] - Received Event `source` is nil")
        XCTAssertEqual(receivedEventSource, Constants.predefinedEventSource, "[PredefinedEvent] - Received Event source is not equal to `\(Constants.predefinedEventSource)`")
        XCTAssertNotNil(receivedEventSubject, "[PredefinedEvent] - Received Event `subject` is nil")
        XCTAssertEqual(receivedEventSubject, Constants.predefinedEventSubject, "[PredefinedEvent] - Received Event subject is not equal to `\(Constants.predefinedEventSubject)`")
    }
    
    func testPostingCustomEvent() {
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
                                        "parameters": [:]
                                    ])
        EventsBus.post(event)
        
        XCTAssertNotNil(receivedEventData, "[CustomEvent] - Received Event `data` is nil")
        XCTAssertNotNil(receivedEventSource, "[CustomEvent] - Received Event `source` is nil")
        XCTAssertEqual(receivedEventSource, Constants.customEventSource, "[CustomEvent] - Received Event source is not equal to `\(Constants.customEventSource)`")
        XCTAssertNotNil(receivedEventSubject, "[CustomEvent] - Received Event `subject` is nil")
        XCTAssertEqual(receivedEventSubject, Constants.customEventSubject, "[CustomEvent] - Received Event subject is not equal to `\(Constants.customEventSubject)`")
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
