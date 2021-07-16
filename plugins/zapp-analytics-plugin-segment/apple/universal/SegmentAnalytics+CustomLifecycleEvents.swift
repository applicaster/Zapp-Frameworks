//
//  SegmentAnalytics+CustomLifecycleEvents.swift
//  SegmentAnalytics
//
//  Created by Alex Zchut on 15/07/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import Foundation
import ZappCore

extension SegmentAnalytics {
    func sendCustomLifecycleEvents() {
        sendAppLaunchedEvent()
    }

    func sendAppLaunchedEvent() {
        guard didSentAppLaunchedEvent == false,
              let currentVersion = FacadeConnector.connector?.applicationData?.appVersion(),
              let currentBuild = FacadeConnector.connector?.applicationData?.appBuild() else {
            return
        }

        let launchOptions = FacadeConnector.connector?.applicationData?.launchOptions()

        var parameters = [
            "from_background": NSNumber(booleanLiteral: false),
            "version": currentVersion as NSString,
            "build": currentBuild as NSString,
            "referring_application": launchOptions?[UIApplication.LaunchOptionsKey.sourceApplication] as? NSString ?? ""]

        if let url = launchOptions?[UIApplication.LaunchOptionsKey.url] as? NSURL {
            parameters["url"] = url
        } else {
            parameters["url"] = "" as NSString
        }
        trackEvent("Application Opened", parameters: parameters)
        didSentAppLaunchedEvent = true
    }

    var didSentAppLaunchedEvent: Bool {
        set {
            _ = FacadeConnector.connector?.storage?.sessionStorageSetValue(for: Params.appLaunchedStorageKey,
                                                                           value: "\(newValue)",
                                                                           namespace: Params.pluginIdentifier)
        }

        get {
            guard let value = FacadeConnector.connector?.storage?.sessionStorageValue(for: Params.appLaunchedStorageKey,
                                                                                      namespace: Params.pluginIdentifier) else {
                return false
            }

            return value.boolValue
        }
    }
}
