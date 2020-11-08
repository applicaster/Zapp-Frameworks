//
//  APAnalyticsProviderAppsFlyer.swift
//  ZappAnalyticsProviderAppsFlyer
//
//  Created by Miri on 31/01/2017.
//  Updated by Alex Zchut on 05/11/2020
//

import AppsFlyerLib
import ZappAnalyticsPluginsSDK

class APAnalyticsProviderAppsFlyer: ZPAnalyticsProvider {
    
    let appsflyer_key  =  "appsflyer_key"
    let apple_app_id =   "apple_app_id"

    override public func getKey() -> String {
        return "appsflyer"
    }
    
    override open func configureProvider() -> Bool {
        var retValue = false
        
        let appsflyerKey = self.providerProperties[appsflyer_key] as? String
        let appleAppId = self.providerProperties[apple_app_id] as? String
        
        if let appsflyerKey = appsflyerKey, appsflyerKey.isNotEmptyOrWhiteSpaces() {
            if let appleAppId = appleAppId, appleAppId.isNotEmptyOrWhiteSpaces() {
                AppsFlyerLib.shared().appsFlyerDevKey = appsflyerKey
                AppsFlyerLib.shared().appleAppID = appleAppId
                AppsFlyerLib.shared().delegate = self
                AppsFlyerLib.shared().isDebug = false
                
                AppsFlyerLib.shared().start()
                retValue = true
            }
        }
        
        return retValue
    }
    
    override open func trackEvent(_ eventName:String) {
        self.trackEvent(eventName, parameters: [String:NSObject]())
    }
    
    override open func trackEvent(_ eventName:String, parameters:[String:NSObject]) {
        super.trackEvent(eventName, parameters: parameters)
        AppsFlyerLib.shared().logEvent(eventName, withValues: parameters)
    }
    
    override open func trackEvent(_ eventName:String, timed:Bool) {
        self.trackEvent(eventName)
    }
    
    override open func trackEvent(_ eventName:String, parameters:[String:NSObject], timed:Bool) {
        self.trackEvent(eventName, parameters: parameters)
    }
    
}

extension APAnalyticsProviderAppsFlyer: AppsFlyerLibDelegate {
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        //
    }
    
    func onConversionDataFail(_ error: Error) {
        //
    }
    
    
}
