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
        static let type = "type"
        static let parameters = "parameters"
        static let name = "name"
        static let screenTitle = "screenTitle"
        static let url = "url"
    }

    func subscribeToEventsBus() {
        FacadeConnector.connector?.eventsBus?.subscribe(self,
                                                       name: EventsBusPredefinedEvent.analytics,
                                                       handler: { content in
                                                           self.sendEvent(userInfo: content?.userInfo)
                                                       })
    }

    func sendEvent(userInfo: [AnyHashable: Any]?) {
        var type: EventsBusAnalyticsTypes = .undefined
        let parameters = userInfo?[Constants.parameters] as? [String: Any] ?? [:]

        if let eventType = userInfo?[Constants.type] as? String {
            type = EventsBusAnalyticsTypes(rawValue: eventType) ?? .undefined
        } else if let eventType = userInfo?[Constants.type] as? EventsBusAnalyticsTypes {
            type = eventType
        }

        switch type {
        case .sendEvent:
            guard let name = userInfo?[Constants.name] as? String else {
                return
            }
            sendEvent(name: name, parameters: parameters)
        case .sendScreenEvent:
            guard let screenTitle = userInfo?[Constants.screenTitle] as? String else {
                return
            }
            sendScreenEvent(screenTitle: screenTitle, parameters: parameters)
        case .startObserveTimedEvent:
            guard let name = userInfo?[Constants.name] as? String else {
                return
            }
            startObserveTimedEvent(name: name, parameters: parameters)
        case .stopObserveTimedEvent:
            guard let name = userInfo?[Constants.name] as? String else {
                return
            }
            stopObserveTimedEvent(name, parameters: parameters)
        case .trackURL:
            let parameters = userInfo?[Constants.url] as? URL
            trackURL(url: parameters)

        default:
            break
        }
    }
}
