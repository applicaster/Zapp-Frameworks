//
//  APAnalyticsProviderChartbeat.swift
//  ZappAnalyticsPluginChartbeat
//
//  Created by Alex Zchut on 19/11/2020.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Chartbeat
import ZappAnalyticsPluginsSDK
import ZappCore

open class APAnalyticsProviderChartbeat: ZPAnalyticsProvider {
    let kAccountID = "account_id"
    let kDomain = "domain"

    struct Events {
        static let EventArticleClicked = "Article Clicked"
        static let EventPlayWasTriggered = "Play was Triggered"
        static let EventSideMenuAreaSwitched = "Side Menu: Area Switched"
        static let EventLiveScreenKey = "Live Screen"
        static let EventKanPlayerPlayItem = "KanPlayerPlayItem"
    }

    override open func getKey() -> String {
        return "chartbeat"
    }

    override open func configureProvider() -> Bool {
        guard let accountString = providerProperties[kAccountID] as? String,
            let accountInt = Int32(accountString),
            let domain = providerProperties[kDomain] as? String,
            domain.isNotEmptyOrWhiteSpaces() else {
            return false
        }

        CBTracker.shared()?.setupTracker(withAccountId: accountInt, domain: domain)
        return true
    }

    override open func trackEvent(_ eventName: String) {
        CBTracker.shared()?.trackView(nil, viewId: eventName, title: eventName)
    }

    override open func trackEvent(_ eventName: String, parameters: [String: NSObject]) {
        super.trackEvent(eventName, parameters: parameters)

        CBTracker.shared()?.trackView(nil, viewId: eventName, title: eventName)
    }

    override open func trackEvent(_ eventName: String, timed: Bool) {
        trackEvent(eventName)
    }

    override open func trackEvent(_ eventName: String, parameters: [String: NSObject], timed: Bool) {
        if timed {
            trackEvent(eventName, timed: timed)
        } else {
            trackEvent(eventName, parameters: parameters)
        }
    }

    override open func endTimedEvent(_ eventName: String, parameters: [String: NSObject]) {
        trackEvent(eventName, parameters: parameters)
    }

    override open func trackScreenView(_ screenName: String, parameters: [String: NSObject]) {
        CBTracker.shared()?.trackView(nil, viewId: screenName, title: screenName)
    }
}
