//
//  AnalyticsManager+EventsBus.swift
//  ZappApple
//
//  Created by Alex Zchut on 15/02/2021.
//

import Foundation
import ZappCore

extension AnalyticsManager {
    struct Constants {
        static let event = "event"
        static let type = "type"
        static let parameters = "parameters"
        static let name = "name"
        static let screenTitle = "screenTitle"
        static let url = "url"
    }

    func subscribeToEventsBus() {
        EventsBus.subscribe(self,
                            topic: EventsBusTopic(type: .analytics),
                            handler: { content in
                                self.sendEvent(with: content)
                            })
    }

    func fetchEventDetails(from content: Notification?) -> EventsBus.Event? {
        return content?.userInfo?[Constants.event] as? EventsBus.Event
    }

    func sendEvent(with content: Notification?) {
        var type: EventsBusAnalyticsTopicSubjects = .undefined
        guard let eventDetails = fetchEventDetails(from: content) else {
            return
        }

        if let eventType = eventDetails.subject {
            type = EventsBusAnalyticsTopicSubjects(rawValue: eventType) ?? .undefined
        }

        let parameters = eventDetails.data?[Constants.parameters] as? [String: Any]
        let name = eventDetails.data?[Constants.name] as? String ?? ""
        let screenTitle = eventDetails.data?[Constants.screenTitle] as? String ?? ""
        let url = eventDetails.data?[Constants.url] as? URL

        switch type {
        case .sendEvent:
            sendEvent(name: name,
                      parameters: parameters)
        case .sendScreenEvent:
            sendScreenEvent(screenTitle: screenTitle,
                            parameters: parameters)
        case .startObserveTimedEvent:
            startObserveTimedEvent(name: name,
                                   parameters: parameters)
        case .stopObserveTimedEvent:
            stopObserveTimedEvent(name,
                                  parameters: parameters)
        case .trackURL:
            trackURL(url: url)
        default:
            break
        }
    }
}
