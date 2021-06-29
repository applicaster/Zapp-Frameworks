//
//  GemiusAnalytics+AdEvents.swift
//  GemiusAnalytics
//
//  Created by Alex Zchut on 21/06/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import Foundation
import GemiusSDK

extension GemiusAnalytics {
    struct ScreenEvents {
        static let home = "Home screen: viewed"
        static let someScreen = "Screen viewed: "
        static let webPageLoaded = "Loaded webview page"
        static let tapNavbarBackButton = "Tap Navbar Back Button"
    }

    struct ScreenEventsParams {
        static let url = "URL"
        static let trigger = "Trigger"
    }

    func shouldHandleScreenEvents(for eventName: String, parameters: [String: NSObject]) -> Bool {
        var retValue = false

        if eventName.contains(ScreenEvents.home) {
            let params = ["Screen": "Home"]

            retValue = proceedScreenEvent(eventName,
                                          params: params)

        } else if eventName.contains(ScreenEvents.someScreen) {
            let params = ["Screen": eventName]

            retValue = proceedScreenEvent(eventName,
                                          params: params)

        } else if eventName.contains(ScreenEvents.webPageLoaded) {
            guard let url = parameters[ScreenEventsParams.url] as? String else {
                return false
            }

            let params = ["Type": eventName,
                          "url": url]

            retValue = proceedScreenEvent(eventName,
                                          params: params)

        } else if eventName == ScreenEvents.tapNavbarBackButton {
            var params = ["Type": eventName]
            if let trigger = parameters[ScreenEventsParams.trigger] as? String {
                params["Source"] = trigger
            }

            retValue = proceedScreenEvent(eventName,
                                          type: .EVENT_ACTION,
                                          params: params)
        }

        return retValue
    }

    fileprivate func proceedScreenEvent(_ eventName: String, type: GEMEventType = .EVENT_FULL_PAGEVIEW, params: [String: String]) -> Bool {
        let event = GEMAudienceEvent()
        event.eventType = type
        event.scriptIdentifier = scriptIdentifier
        for (key, value) in params {
            if key.count > 0 && value.count > 0 {
                event.addExtraParameter(key, value: value)
            }
        }
        event.send()

        lastProceededScreenEvent = eventName
        return true
    }
}
