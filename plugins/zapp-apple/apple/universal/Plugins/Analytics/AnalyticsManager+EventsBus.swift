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
                            subject: EventsBusAnalyticsTopicSubjects.sendEvent.rawValue,
                            handler: { content in
                                guard let eventDetails = self.getEventDetails(from: content) else {
                                    return
                                }
                                self.sendEvent(name: eventDetails.name,
                                               parameters: eventDetails.parameters)
                            })

        EventsBus.subscribe(self,
                            topic: EventsBusTopic(type: .analytics),
                            subject: EventsBusAnalyticsTopicSubjects.sendScreenEvent.rawValue,
                            handler: { content in
                                guard let eventDetails = self.getEventDetails(from: content) else {
                                    return
                                }
                                self.sendScreenEvent(screenTitle: eventDetails.screenTitle,
                                                     parameters: eventDetails.parameters)
                            })

        EventsBus.subscribe(self,
                            topic: EventsBusTopic(type: .analytics),
                            subject: EventsBusAnalyticsTopicSubjects.startObserveTimedEvent.rawValue,
                            handler: { content in
                                guard let eventDetails = self.getEventDetails(from: content) else {
                                    return
                                }
                                self.startObserveTimedEvent(name: eventDetails.name,
                                                            parameters: eventDetails.parameters)
                            })

        EventsBus.subscribe(self,
                            topic: EventsBusTopic(type: .analytics),
                            subject: EventsBusAnalyticsTopicSubjects.stopObserveTimedEvent.rawValue,
                            handler: { content in
                                guard let eventDetails = self.getEventDetails(from: content) else {
                                    return
                                }
                                self.stopObserveTimedEvent(eventDetails.name,
                                                           parameters: eventDetails.parameters)
                            })

        EventsBus.subscribe(self,
                            topic: EventsBusTopic(type: .analytics),
                            subject: EventsBusAnalyticsTopicSubjects.trackURL.rawValue,
                            handler: { content in
                                guard let eventDetails = self.getEventDetails(from: content) else {
                                    return
                                }
                                self.trackURL(url: eventDetails.url)

                            })
    }

    func fetchEventDetails(from content: Notification?) -> EventsBus.Event? {
        return content?.userInfo?[Constants.event] as? EventsBus.Event
    }

    func getEventDetails(from content: Notification?) -> (name: String,
                                                          parameters: [String: Any]?,
                                                          screenTitle: String,
                                                          url: URL?)? {
        guard let eventDetails = fetchEventDetails(from: content) else {
            return nil
        }

        let parameters = eventDetails.data?[Constants.parameters] as? [String: Any]
        let name = eventDetails.data?[Constants.name] as? String ?? ""
        let screenTitle = eventDetails.data?[Constants.screenTitle] as? String ?? ""
        let url = eventDetails.data?[Constants.url] as? URL

        return (name, parameters, screenTitle, url)
    }
}
