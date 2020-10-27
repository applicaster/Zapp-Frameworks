/*!
 * @type              APAnalyticsProviderFirebase.swift
 * @abstract          Implement Firebase analytics agent
 * @discussion        Because firebase limitation we encode special characters (LEGENT_JSON).
 * @additional tag    Firebase
 * @additional tag    analytics
 */

//  Created by Elad Ben david on 19/01/2017.
//  Copyright © 2017 Applicaster Ltd. All rights reserved.
//

import Firebase
import ZappAnalyticsPluginsSDK
import ZappPlugins

open class APAnalyticsProviderFirebase: ZPAnalyticsProvider {
        
    public let MAX_PARAM_NAME_CHARACTERS_LONG  :Int = 40
    public let MAX_PARAM_VALUE_CHARACTERS_LONG :Int = 100
    public let FIREBASE_PREFIX : String = "Firebase_"
    public let APPLICASTER_PREFIX : String = "applicaster_"
    private var LEGENT : Dictionary<String, String> = [:]
    private var LEGENT_JSON : String = "{\" \":\"__\",\"_\":\"_0\",\"-\":\"_1\",\":\":\"_2\",\"'\":\"_3\",\".\":\"_4\",\",\":\"_5\",\"/\":\"_6\",\"\\\\\":\"_7\",\"(\":\"_8\",\")\":\"_A\",\"?\":\"_B\",\"\\\"\":\"_C\",\"!\":\"_D\",\"@\":\"_E\",\"#\":\"_F\",\"$\":\"_G\",\"%\":\"_H\",\"^\":\"_I\",\"&\":\"_J\",\"*\":\"_K\",\"=\":\"_M\",\"+\":\"_N\",\"~\":\"_L\",\"`\":\"_O\",\"|\":\"_P\",\";\":\"_Q\",\"[\":\"_R\",\"]\":\"_S\",\"}\":\"_T\",\"{\":\"_U\"}"
    private let USER_PROPERTIES_EVENT_NAME = Notification.Name("userProperties")
    
    var isUserProfileEnabled = true
    
    //Firebase User Profile
    struct UserProfile {
        static let created = "$created"
        static let iOSDevices = "$ios_devices"
    }
    
    //Json Keys
    struct JsonKeys {
        static let sendUserData = "Send_User_Data"
    }
    
    //Constants used for User ID tracking functionality
    struct UserIDConstants {
        static let userIDJSONConfig = "user_id"
        static let familyIDLocalStorageKey = "app_family_id"
        static let userIDCompareString = "allow-tracking-user-id-for-app-family-"
        static let userIDLocalStorageKey = "user_id"
        static let loginNamespace = "login"
    }
    
    override open func getKey() -> String {
        return "firebase"
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: USER_PROPERTIES_EVENT_NAME,
                                                  object: nil)
    }
    
    override open func configureProvider() -> Bool {
        initLegent()
        if let path = Bundle.main.path(forResource: "GoogleService-Info",
                                       ofType: "plist") {
            if let plistDictionary = NSDictionary(contentsOfFile: path){
                if  plistDictionary.allKeys.count > 0 {
                    if (FirebaseApp.app() == nil) {
                        FirebaseApp.configure()
                        
                        if let people = self.providerProperties[JsonKeys.sendUserData] as? String {
                            self.isUserProfileEnabled = people.boolValue()
                        }
                    }
                    
                    //Listen to react native broadcase events
                    NotificationCenter.default.addObserver(self,
                                                           selector: #selector(onDidReceiveUserProperties(_:)),
                                                           name: USER_PROPERTIES_EVENT_NAME,
                                                           object: nil)
                    
                    return true
                }
            }
        }
        
        return false
    }
    
    override open func trackEvent(_ eventName:String, parameters:[String:NSObject]) {
        super.trackEvent(eventName, parameters: parameters)
        var combinedParameters = ZPAnalyticsProvider.defaultProperties(self.defaultEventProperties, combinedWithEventParams: parameters)

        let eventName = refactorParamName(eventName: eventName)

        if combinedParameters.isEmpty == true {
            Analytics.logEvent(eventName, parameters: nil)
        }
        else{
            combinedParameters = refactorEventParameters(parameters: combinedParameters)
            Analytics.logEvent(eventName, parameters:combinedParameters)
        }
    }

    override open func trackEvent(_ eventName:String, message: String, exception:NSException) {
        trackEvent(eventName, parameters: [String : NSObject]())
    }
    
    override open func trackEvent(_ eventName:String, message: String, error: NSError) {
        trackEvent(eventName, parameters: [String : NSObject]())

    }
    
    override open func trackEvent(_ eventName:String, timed:Bool) {
        if timed {
            registerTimedEvent(eventName, parameters: nil)
        } else {
            trackEvent(eventName, parameters: [String : NSObject]())
        }
    }
    
    override open func trackEvent(_ eventName:String, parameters: [String:NSObject], timed:Bool) {
        if timed {
            registerTimedEvent(eventName, parameters: parameters)
        } else {
            trackEvent(eventName, parameters: parameters)
        }
    }
    
    override open func trackEvent(_ eventName:String){
        trackEvent(eventName, parameters: [String : NSObject]())
    }
    
    override open func endTimedEvent(_ eventName: String, parameters: [String : NSObject]) {
        processEndTimedEvent(eventName, parameters: parameters)
    }
    
    override open func setUserProfile(genericUserProperties dictGenericUserProperties: [String : NSObject],
                                      piiUserProperties dictPiiUserProperties: [String : NSObject]) {
        if isUserProfileEnabled {
            var firebaseParameters = [String : NSObject]()
            for (key, value) in dictGenericUserProperties {
                switch key {
                case kUserPropertiesCreatedKey:
                    firebaseParameters[UserProfile.created] = value
                case kUserPropertiesiOSDevicesKey:
                    firebaseParameters[UserProfile.iOSDevices] = value
                default:
                    firebaseParameters[key] = value
                }
            }
            
            for (key, value) in firebaseParameters {
                guard let value = value as? String else {
                    continue
                }
                Analytics.setUserProperty(value, forName: key)
            }
            
            checkUserID()
        }
    }

    //Method that add the user id only if it is configured as allow-tracking-user-id-for-app-family-<APP_FAMILY_ID> in the plugin configurations
    fileprivate func checkUserID() {
        guard let userIDParameter = configurationJSON?[UserIDConstants.userIDJSONConfig] as? String,
            let familyID = ZAAppConnector.sharedInstance().storageDelegate?.localStorageValue(for:UserIDConstants.familyIDLocalStorageKey, namespace:nil),
            let userID = ZAAppConnector.sharedInstance().storageDelegate?.localStorageValue(for:UserIDConstants.userIDLocalStorageKey, namespace:UserIDConstants.loginNamespace) else {
                return
        }

        if (userIDParameter == "\(UserIDConstants.userIDCompareString)\(familyID)") {
            Analytics.setUserID(userID)
        }
    }
    
    /*
     * loading LEGENT Dictionary according LEGENT_JSON
     */
    public func initLegent() {
        LEGENT = convertToDictionary(jsonString: LEGENT_JSON)
    }
    
    /**
     * @param eventValue the text we should encode according param value limitations.
     * @return encoded string base on eventValue
     * @discussion  Firebase param value limitations:
     * @discussion  **********************
     * @discussion  1. Param values can be up to 100 characters long.
     * @discussion  2. The "firebase_" prefix is reserved and should not be used so APPLICASTER_PREFIX will be added.
     */
    public func  refactorParamValue(eventValue:  String) -> String{
        var returnValue:String = eventValue
        
        if (returnValue.hasPrefix(FIREBASE_PREFIX)) {
            returnValue = APPLICASTER_PREFIX + returnValue;
        }
        
        //Param values can be up to 100 characters long.
        if (returnValue.count > MAX_PARAM_VALUE_CHARACTERS_LONG) {
            returnValue = String(returnValue[returnValue.startIndex..<returnValue.index(returnValue.startIndex, offsetBy: MAX_PARAM_VALUE_CHARACTERS_LONG)])
        }
        
        return returnValue;
    }
    
    /*
     * @param eventValue the text we should encode according param name limitations.
     * @return encoded string base on eventName
     * @discussion  Firebase param names limitations:
     * @discussion  **********************
     * @discussion  1. Param names can be up to 40 characters long.
     * @discussion  2. Contain alphanumeric characters and underscores ("_").
     * @discussion  3. must start with an alphabetic character.
     * @discussion  4. The "firebase_" prefix is reserved and should not be used so APPLICASTER_PREFIX will be added.
     */
    public func refactorParamName( eventName: String) -> String {
        var returnValue:String = eventName
        //Contain alphanumeric characters and underscores ("_").
        returnValue = recursiveEncodeAlphanumericCharacters(eventName: returnValue)
        
        if (returnValue.hasPrefix(FIREBASE_PREFIX)) {
            returnValue = APPLICASTER_PREFIX + returnValue
        }
        
        // 3. must start with an alphabetic chaacter.
        if returnValue.isEmpty == false {
            switch returnValue[returnValue.startIndex] {
            case "0"..."9" , "a"..."z", "A"..."Z":
                break
            default:
                returnValue = APPLICASTER_PREFIX + returnValue;
                break
            }
        }
        
        //Param names can be up to 40 characters long.
        if (returnValue.count > MAX_PARAM_NAME_CHARACTERS_LONG) {
            returnValue = String(returnValue[returnValue.startIndex..<returnValue.index(returnValue.startIndex, offsetBy: MAX_PARAM_NAME_CHARACTERS_LONG)])
        }
        
        return returnValue;
    }
    
    /*
     * Convert json string to dictionary
     */
    private func convertToDictionary(jsonString: String) -> [String: String] {
        guard let data = jsonString.data(using: String.Encoding.utf8) else {
            return [:]
        }
        
        guard let jsonDictionary = try? JSONSerialization.jsonObject(with: data, options: [] ) as? [String: String] else {
            return [:]
        }
        
        return jsonDictionary
    }
    
    /*
     * This function replace all the forbidden charcters with new one, according the legend dictionary.
    */
    private func recursiveEncodeAlphanumericCharacters( eventName: String ) -> String {
        let name:String = eventName
        if name.count > 0 {
            let send = name.index(name.startIndex, offsetBy: 1)
            let sendvalue = String(name[send..<name.endIndex])
            if let prefix = LEGENT[name.getFirstCharacter! as String] {
                return prefix + recursiveEncodeAlphanumericCharacters( eventName: sendvalue)
            }else{
                return name.getFirstCharacter! + recursiveEncodeAlphanumericCharacters( eventName: sendvalue)
            }
        }
        return ""
    }
    
    /*
     * Validate and refactor parameters before sending event
     */
    public func refactorEventParameters(parameters: [String: NSObject]) -> [String: NSObject]{
        var validateParameters = [String: NSObject]()
        for (key, value) in parameters {
            let validateParamName = refactorParamName(eventName:key)
            var validateParamValue = value
            if ((value as? String) != nil){
                validateParamValue = refactorParamValue(eventValue:value as! String) as NSObject
            }
            validateParameters[validateParamName] = validateParamValue
        }
        return validateParameters
    }
    
    public func setUserProfileWithGenericUserProperties(genericUserProperties: [String : NSObject],
                                                        piiUserProperties: [String : NSObject]) {
        
    }
    
    /*
    * Trigger check user ID by react native side
    */
    @objc func onDidReceiveUserProperties(_ notification:Notification) {
        checkUserID()
    }
}
