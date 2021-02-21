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
                            topic: EventsBusTopic(type: .analytics(subtype: .sendEvent)),
                            handler: { content in
                                let eventDetails = self.eventDetails(content)
                                self.sendEvent(name: eventDetails.name,
                                               parameters: eventDetails.parameters)
                            })
        
        EventsBus.subscribe(self,
                            topic: EventsBusTopic(type: .analytics(subtype: .sendScreenEvent)),
                            handler: { content in
                                let eventDetails = self.eventDetails(content)
                                self.sendScreenEvent(screenTitle: eventDetails.name,
                                                     parameters: eventDetails.parameters)
                            })
        
        EventsBus.subscribe(self,
                            topic: EventsBusTopic(type: .analytics(subtype: .startObserveTimedEvent)),
                            handler: { content in
                                let eventDetails = self.eventDetails(content)
                                self.startObserveTimedEvent(name: eventDetails.name,
                                                            parameters: eventDetails.parameters)
                            })
        
        EventsBus.subscribe(self,
                            topic: EventsBusTopic(type: .analytics(subtype: .stopObserveTimedEvent)),
                            handler: { content in
                                let eventDetails = self.eventDetails(content)
                                self.stopObserveTimedEvent(eventDetails.name,
                                                           parameters: eventDetails.parameters)
                            })
        
        EventsBus.subscribe(self,
                            topic: EventsBusTopic(type: .analytics(subtype: .trackURL)),
                            handler: { content in
                                let eventDetails = self.eventDetails(content)
                                self.trackURL(url: eventDetails.url)
                            })
    }

    func eventDetails(_ notification: Notification?) -> (name: String,
                                                         parameters: [String: Any]?,
                                                         url: URL?)  {
        guard let event = notification?.userInfo?[Constants.event] as? EventsBus.Event,
              let data = event.data else {
            return ("", nil, nil)
        }
        
        let parameters = data[Constants.parameters] as? [String: Any]
        let name = data[Constants.name] as? String ?? ""
        let url = data[Constants.url] as? URL
        
        return (name, parameters, url)
    }
}
