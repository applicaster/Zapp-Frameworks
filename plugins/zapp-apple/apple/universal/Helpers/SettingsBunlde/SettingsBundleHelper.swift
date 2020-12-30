//
//  SettingsBundleHelper.swift
//  ZappApple
//
//  Created by Alex Zchut on 26/10/2020.
//

import Foundation

public enum SettingsBundleParameters: String {
    case loggerAssistanceRemoteEventsLogging = "logger_assistance_remote_events_logging"
}

public class SettingsBundleHelper {
    public class func getSettingsBundleBoolValue(forKey key: SettingsBundleParameters) -> Bool {
        return UserDefaults.standard.bool(forKey: key.rawValue)
    }
    
    public class func setSettingsBundleBoolValue(forKey key: SettingsBundleParameters, value: Bool) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }

    public class func handleChangesIfNeeded() {
        handleLoggerAssistance(for: .loggerAssistanceRemoteEventsLogging, savedKey: .loggerAssistanceRemoteEventsLogging)
    }

    class func handleLoggerAssistance(for key: SettingsBundleParameters, savedKey: SettingsBundleParametersSavedValues) {
        let newValue = getSettingsBundleBoolValue(forKey: key)
        let oldValue = getSettingsBundleLastUsedBoolValue(forKey: savedKey)
        if newValue != oldValue {
            if newValue == true,
                let urlScheme = APSwiftUtils.appUrlScheme,
                let url = URL(string: "\(urlScheme)://settings?type=\(key.rawValue)&value=\(newValue)") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                setSettingsBundleLastUsedBoolValue(forKey: savedKey, value: newValue)
            }
        }
    }
}

extension SettingsBundleHelper {
    public enum SettingsBundleParametersSavedValues: String {
        case loggerAssistanceRemoteEventsLogging = "logger_assistance_remote_events_logging_value"

    }

    public class func getSettingsBundleLastUsedBoolValue(forKey key: SettingsBundleParametersSavedValues) -> Bool {
        return UserDefaults.standard.bool(forKey: key.rawValue)
    }

    class func setSettingsBundleLastUsedBoolValue(forKey key: SettingsBundleParametersSavedValues, value: Bool) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }
}
