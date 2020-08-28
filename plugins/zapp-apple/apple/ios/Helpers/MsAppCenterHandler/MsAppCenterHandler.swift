//
//  MsAppCenterDistributionHandler.swift
//  ZappApple
//
//  Created by Anton Kononenko on 10/4/19.
//  Copyright © 2019 Anton Kononenko. All rights reserved.
//

import AppCenter
//import AppCenterAnalytics
import AppCenterDistribute
import Foundation
import XrayLogger

#if canImport(AppCenterCrashes)
    import AppCenterCrashes
#endif

public class MsAppCenterHandler: NSObject {
    lazy var logger = Logger.getLogger(for: AppCenterLogs.subsystem)

    public func configure() {
        guard let appSecret = FeaturesCustomization.msAppCenterAppSecret() else {
            logger?.warningLog(template: AppCenterLogs.appCenterConfigureNoSecret)
            return
        }

//        var services: [MSServiceAbstract.Type] = [MSDistribute.self,
//                                                  MSAnalytics.self]
        var services: [MSServiceAbstract.Type] = [MSDistribute.self]
        if let crashes = crashesSerice() {
            services.append(crashes)
        }
        MSAppCenter.start(appSecret,
                          withServices: services)

        configureDistribution()
        logger?.debugLog(template: AppCenterLogs.appCenterConfigure,
                         data: ["app_secret": appSecret,
                                "distribute_service_enabled": true,
                                "analytics_service_enabled": true,
                                "crashes_service_enabled": crashesSerice() != nil ? true : false])
    }

    func configureDistribution() {
        // disable until app fully loaded
        MSDistribute.setEnabled(false)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(checkUpdatesForNewVersions),
            name: NSNotification.Name(kMSAppCenterCheckForUpdatesNotification),
            object: nil)

        logger?.verboseLog(template: AppCenterLogs.appCenterConfigureDiscribution,
                           data: ["starting_observe_key": kMSAppCenterCheckForUpdatesNotification,
                                  "selector": "checkUpdatesForNewVersions:"])
    }

    func crashesSerice() -> MSServiceAbstract.Type? {
        #if canImport(AppCenterCrashes)
            return MSCrashes.self
        #else
            return nil
        #endif
    }

    @objc func checkUpdatesForNewVersions(notification: Notification) {
        MSDistribute.setEnabled(true)
    }
}
