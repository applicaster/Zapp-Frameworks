//
//  APAnalyticsProviderMixpanel.swift
//  ZappAnalyticsPluginMixpanel
//
//  Created by Alex Zchut on 04/02/2018.
//  Copyright © 2018 Applicaster Ltd. All rights reserved.
//

import Mixpanel
import ZappAnalyticsPluginsSDK
import ZappCore
import ZappPlugins

@objc open class APAnalyticsProviderMixpanel: ZPAnalyticsProvider {

    static var currentMixpanelToken = ""

    var isUserProfileEnabled = false
    var isEngagementEnabled = false
    var isPiiFilteredOut = false
    var isUserProfilePropertiesRequired = false
    var isUserProfilePropertiesProceeded = false
    var pushDeviceToken: Data? {
        didSet {
            self.sendPushDeviceToken()
        }
    }

    //Mixpanel User Profile
    struct UserProfile {
        static let created = "$created"
        static let email = "$email"
        static let phone = "$phone"
        static let firstName = "$first_name"
        static let lastName = "$last_name"
        static let name = "$name"
        static let userName = "$username"
        static let iOSDevices = "$ios_devices"
    }

    //Json Keys
    struct JsonKeys {
        static let token = "token"
        static let people = "people"
        static let requirePeopleProperties = "require_people_properties"
        static let engagement = "engagement"
        static let piiFilterOut = "filter_out_pii"
    }

    static public func mixpanelToken() -> String {
        return currentMixpanelToken
    }

    override open func getKey() -> String {
        return "mixpanel"
    }

    override open func configureProvider() -> Bool {
        var success = false

        if let token = self.providerProperties[JsonKeys.token] as? String, String.isNotEmptyOrWhitespace(token) {
            Mixpanel.initialize(token: token)
            if let people = self.providerProperties[JsonKeys.people] as? String {
                self.isUserProfileEnabled = people.boolValue()
            }

            if let requirePeopleProperties = self.providerProperties[JsonKeys.requirePeopleProperties] as? String {
                self.isUserProfilePropertiesRequired = requirePeopleProperties.boolValue()
            }

            if let engagement = self.providerProperties[JsonKeys.engagement] as? String {
                self.isEngagementEnabled = engagement.boolValue()
            }

            if let piiFilterOut = self.providerProperties[JsonKeys.piiFilterOut] as? String {
                self.isPiiFilteredOut = piiFilterOut.boolValue()
            }

            let kDeviceID = "uuid"
            var deviceID: String?
            if let qbDeviceID = FacadeConnector.connector?.storage?.sessionStorageValue(for: kDeviceID,
                                                                                      namespace: nil) {
                deviceID = qbDeviceID
            }
            else if let legacyDeviceID = ZAAppConnector.sharedInstance().storageDelegate?.sessionStorageValue(for: kDeviceID,
                                                                                                        namespace: nil) {
                deviceID = legacyDeviceID
            }
            
            if let deviceID = deviceID {
                Mixpanel.mainInstance().identify(distinctId: deviceID)

                //save current token
                APAnalyticsProviderMixpanel.currentMixpanelToken = token

                success = true
            }
        }

        return success
    }

    func sendPushDeviceToken() {
        if let deviceToken = self.pushDeviceToken,
            !deviceToken.isEmpty,
            self.isUserProfileEnabled,
            (!self.isUserProfilePropertiesRequired || self.isUserProfilePropertiesProceeded) {
            Mixpanel.mainInstance().people?.addPushDeviceToken(deviceToken)
        }
    }

    open override func updateDefaultEventProperties(_ eventProperties: [String:NSObject]) {
        super.updateDefaultEventProperties(eventProperties)
        if let properties = eventProperties as? Properties {
            Mixpanel.mainInstance().registerSuperProperties(properties)
        }
    }

    open override func setPushNotificationDeviceToken(_ deviceToken: Data) {
        super.setPushNotificationDeviceToken(deviceToken)
        self.pushDeviceToken = deviceToken
    }

    override open func trackEvent(_ eventName:String) {
        if self.isEngagementEnabled {
            Mixpanel.mainInstance().track(event: eventName)
        }
    }

    override open func trackEvent(_ eventName:String, parameters:[String:NSObject]) {
        super.trackEvent(eventName, parameters: parameters)

        if self.isEngagementEnabled {
            let parameters = self.sortPropertiesAlphabeticallyAndCutThemByLimitation(parameters)
            let properties = self.getParametersAsMixpanelProperties(parameters)
            if properties.count > 0 {
                Mixpanel.mainInstance().track(event: eventName, properties: properties)
            }
            else {
                self.trackEvent(eventName)
            }
        }
    }

    override open func trackEvent(_ eventName:String, timed:Bool) {
        if self.isEngagementEnabled {
            if timed {
                Mixpanel.mainInstance().time(event: eventName)
            }
            else {
                self.trackEvent(eventName)
            }
        }
    }

    override open func trackEvent(_ eventName:String, parameters:[String:NSObject], timed:Bool) {
        if timed {
            self.trackEvent(eventName, timed: timed)
        }
        else {
            self.trackEvent(eventName, parameters: parameters)
        }
    }

    open override func endTimedEvent(_ eventName: String, parameters: [String : NSObject]) {
        self.trackEvent(eventName, parameters: parameters)
    }

    func getParametersAsMixpanelProperties(_ properties: [String : NSObject]?) -> Properties {
        //MixpanelType can be either String, Int, UInt, Double, Float, Bool, [MixpanelType], [String: MixpanelType], Date, URL, or NSNull
        var retValue: Properties = [:]
        guard let properties = properties else {
            return retValue
        }

        for (key, value) in properties {
            if let value = value as? String  {
                retValue[key] = value
            }
            else if let value = value as? Int {
                retValue[key] = value
            }
            else if let value = value as? UInt {
                retValue[key] = value
            }
            else if let value = value as? Double {
                retValue[key] = value
            }
            else if let value = value as? Float {
                retValue[key] = value
            }
            else if let value = value as? Bool {
                retValue[key] = value
            }
            else if let value = value as? [MixpanelType] {
                retValue[key] = value
            }
            else if let value = value as? [String: MixpanelType] {
                retValue[key] = value
            }
            else if let value = value as? Date {
                retValue[key] = value
            }
            else if let value = value as? URL {
                retValue[key] = value
            }
            else if let value = value as? NSNull {
                retValue[key] = value
            }
        }
        return retValue
    }

    func setUserProfileWithGenericUserProperties(genericUserProperties: [String : NSObject], piiUserProperties: [String : NSObject]) {
        if isUserProfileEnabled {
            var mixpanelParameters = [String : NSObject]()
            for (key, value) in genericUserProperties {
                if key == kUserPropertiesCreatedKey {
                    mixpanelParameters[UserProfile.created] = value
                }
                else if key == kUserPropertiesiOSDevicesKey {
                    mixpanelParameters[UserProfile.iOSDevices] = value
                }
                else {
                    mixpanelParameters[key] = value
                }
            }

            if !self.isPiiFilteredOut {
                for (key, value) in piiUserProperties {
                    if key == kUserPropertiesEmailKey {
                        mixpanelParameters[UserProfile.email] = value
                    }
                    else if key == kUserPropertiesPhoneKey {
                        mixpanelParameters[UserProfile.phone] = value
                    }
                    else if key == kUserPropertiesFirstNameKey {
                        mixpanelParameters[UserProfile.firstName] = value
                    }
                    else if key == kUserPropertiesLastNameKey {
                        mixpanelParameters[UserProfile.lastName] = value
                    }
                    else if key == kUserPropertiesNameKey {
                        mixpanelParameters[UserProfile.name] = value
                    }
                    else if key == kUserPropertiesUserNameKey {
                        mixpanelParameters[UserProfile.userName] = value
                    }
                }
            }

            //push token is not being sent previously if requires_profile_properties is true
            //so checking if it was true and there are user properties added to mixpanelParameters and pushDeviceToken exists to send it now
            if self.isUserProfilePropertiesRequired && !mixpanelParameters.isEmpty {
                if let deviceToken = self.pushDeviceToken, !deviceToken.isEmpty {
                    Mixpanel.mainInstance().people?.addPushDeviceToken(deviceToken)
                }
                else {
                    //allow sending the token if isUserProfilePropertiesRequired and indicate that user properties  proceeded to be able to send the token when arrived
                    self.isUserProfilePropertiesProceeded = true
                }
            }

            if let parameters = mixpanelParameters as? Properties {
                Mixpanel.mainInstance().people?.set(properties: parameters)
            }
        }
    }
}
