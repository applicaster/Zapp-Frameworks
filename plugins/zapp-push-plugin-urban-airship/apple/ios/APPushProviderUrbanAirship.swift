//
//  APPushProviderUrbanAirship.swift
//  APPushProviderUrbanAirship
//
//  Created by Miri on 16/11/2016.
//  Copyright © 2016 Applicaster Ltd. All rights reserved.
//

import Airship
import ZappPlugins
import ZappPushPluginsSDK

open class APPushProviderUrbanAirship: ZPPushProvider, UARegistrationDelegate, UADeepLinkDelegate {
    let storeAppKey = "store_app_key"
    let storeAppSecret = "store_app_secret"
    let enterpriseAppKey = "enterprise_app_key"
    let enterpriseAppSecret = "enterprise_app_secret"
    let googleAnalyticsAccountId = "google_analytics_account_id"

    var pushCompletionHandler: ((Bool, [String]?) -> Void)?

    override open func getKey() -> String {
        return "urbanairship"
    }

    override open func configureProvider() -> Bool {
        var retValue = false

        let entAppKey = configurationJSON?.object(forKey: enterpriseAppKey) as? String
        let entAppSecret = configurationJSON?.object(forKey: enterpriseAppSecret) as? String
        let stoAppKey = configurationJSON?.object(forKey: storeAppKey) as? String
        let stoAppSecret = configurationJSON?.object(forKey: storeAppSecret) as? String
        let googleAnalyticsId = configurationJSON?.object(forKey: googleAnalyticsAccountId) as? String

        let config = UAConfig.default()
        var isLegacySdkDebug = false
        if let genericDelegate = ZAAppConnector.sharedInstance().genericDelegate,
            genericDelegate.isDebug() == true {
            isLegacySdkDebug = true
        }

        var isEnterpriseBuild = false
        if let bundleIdentifier = Bundle.main.bundleIdentifier,
            bundleIdentifier.contains("com.applicaster.ent.") {
            isEnterpriseBuild = true
        }
        
        let isDebugEnvironment = FacadeConnector.connector?.applicationData?.isDebugEnvironment() ?? false

        if isLegacySdkDebug || isEnterpriseBuild || isDebugEnvironment {
            if let entAppKey = entAppKey, entAppKey.isNotEmptyOrWhiteSpaces(),
                let entAppSecret = entAppSecret, entAppSecret.isNotEmptyOrWhiteSpaces() {
                config.productionAppKey = entAppKey
                config.productionAppSecret = entAppSecret
                config.developmentAppKey = entAppKey
                config.developmentAppSecret = entAppSecret
                retValue = true
            }
        } else {
            if let stoAppKey = stoAppKey, stoAppKey.isNotEmptyOrWhiteSpaces(),
                let stoAppSecret = stoAppSecret, stoAppSecret.isNotEmptyOrWhiteSpaces() {
                config.productionAppKey = stoAppKey
                config.productionAppSecret = stoAppSecret
                retValue = true
            }
        }

        if retValue == true {
            if Thread.isMainThread {
                register(config: config, googleAnalyticsId: googleAnalyticsId)
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.register(config: config, googleAnalyticsId: googleAnalyticsId)
                }
            }
        }
        return retValue
    }

    func register(config: UAConfig, googleAnalyticsId: String?) {
        config.isAutomaticSetupEnabled = true
        UAirship.takeOff(config)
        UAirship.push().userPushNotificationsEnabled = true
        UAirship.push().registrationDelegate = self
        UAirship.shared()?.deepLinkDelegate = self

        if let googleAnalyticsId = googleAnalyticsId,
            googleAnalyticsId.isNotEmptyOrWhiteSpaces() {
            let identifiers = UAirship.shared().analytics.currentAssociatedDeviceIdentifiers()
            // Add the client ID from your Google Anlaytics tracker:
            identifiers.setIdentifier(googleAnalyticsId, forKey: "GA_CID")
            // Update the identifiers
            UAirship.shared().analytics.associateDeviceIdentifiers(identifiers)
        }
    }

    // MARK: - Tags

    func getDeviceTags() -> [String]? {
        return UAChannel.shared()?.tags
    }

    func addTagsToDevice(_ tags: [String]?, completion: @escaping (_ success: Bool, _ tags: [String]?) -> Void) {
        pushCompletionHandler = completion
        if let deviceTags = tags, deviceTags.count > 0 {
            if let channel = UAChannel.shared() {
                channel.addTags(deviceTags)
                UAirship.push()?.updateRegistration()
            }
        }
    }

    func removeTagsToDevice(_ tags: [String]?, completion: @escaping (_ success: Bool, _ tags: [String]?) -> Void) {
        pushCompletionHandler = completion
        if let deviceTags = tags, deviceTags.count > 0 {
            if let channel = UAChannel.shared() {
                channel.removeTags(deviceTags)
                UAirship.push()?.updateRegistration()
            }
        }
    }

    // MARK: - UARegistrationDelegate

    open func registrationSucceeded(forChannelID channelID: String, deviceToken: String) {
        if let pushCompletionHandler = pushCompletionHandler {
            pushCompletionHandler(true, UAChannel.shared()?.tags)
            self.pushCompletionHandler = nil
        }
    }

    open func registrationFailed() {
        if let pushCompletionHandler = pushCompletionHandler {
            pushCompletionHandler(false, UAChannel.shared()?.tags)
            self.pushCompletionHandler = nil
        }
    }

    // MARK: - UIApplicationDelegate

    func didRegisterForRemoteNotificationsWithDeviceToken(_ deviceToken: Data) {
        UAAppIntegration.application(UIApplication.shared, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }

    // MARK: - UADeepLinkDelegate

    public func receivedDeepLink(_ url: URL, completionHandler: @escaping () -> Void) {
        UIApplication.shared.open(url, options: [:]) { _ in
            completionHandler()
        }
    }
}
