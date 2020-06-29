//
//  MsAppCenterDistributionHandler.swift
//  ZappApple
//
//  Created by Anton Kononenko on 10/4/19.
//  Copyright © 2019 Anton Kononenko. All rights reserved.
//

import AppCenter
import AppCenterAnalytics
import AppCenterDistribute
import Foundation

#if canImport(AppCenterCrashes)
    import AppCenterCrashes
#endif

public class MsAppCenterHandler: NSObject {
    public func configure() {
        guard let appSecret = FeaturesCustomization.msAppCenterAppSecret() else {
            return
        }

        var services: [MSServiceAbstract.Type] = [MSDistribute.self,
                                                  MSAnalytics.self]
        if let crashes = crashesSerice() {
            services.append(crashes)
        }
        MSAppCenter.start(appSecret,
                          withServices: services)
        configureDistribution()
    }

    func configureDistribution() {
        // disable until app fully loaded
        MSDistribute.setEnabled(false)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(checkUpdatesForNewVersions),
            name: NSNotification.Name(kMSAppCenterCheckForUpdatesNotification),
            object: nil)
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
