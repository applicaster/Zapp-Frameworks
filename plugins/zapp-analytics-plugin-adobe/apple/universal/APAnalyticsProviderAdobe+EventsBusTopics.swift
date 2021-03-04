//
//  APAnalyticsProviderAdobe+HandleEventsBusTopics.swift
//  ZappAnalyticsPluginAdobe
//
//  Created by Alex Zchut on 17/02/2021.
//

import Foundation
import ZappCore

extension APAnalyticsProviderAdobe {
    func subscribeToEventsBusTopics() {
        EventsBus.subscribe(self,
                            type: "videoAdvertisementsOpportunity") { notification in
            self.adobeAnalyticsObjc?.prepareVideoAdvertisementsOpportunity(notification, completion: { eventName, parameters in
                let trackParameters = parameters as? [String: NSObject] ?? [:]
                self.trackEvent(eventName, parameters: trackParameters)
            })
        }

        EventsBus.subscribe(self,
                            type: "watchVideoAdvertisements") { notification in
            self.adobeAnalyticsObjc?.prepareWatchVideoAdvertisement(notification, completion: { eventName, parameters in
                let trackParameters = parameters as? [String: NSObject] ?? [:]
                self.trackEvent(eventName, parameters: trackParameters)
            })
        }
    }
}
