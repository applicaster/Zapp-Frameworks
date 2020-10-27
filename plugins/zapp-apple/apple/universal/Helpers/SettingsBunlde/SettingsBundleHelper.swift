//
//  SettingsBundleHelper.swift
//  ZappApple
//
//  Created by Alex Zchut on 26/10/2020.
//

import Foundation

public enum SettingsBundleParameters: String {
    case loggerAssistance = "logger_assistance"
}

public class SettingsBundleHelper {
    public class func getSettingsBundleBoolValue(forKey key: SettingsBundleParameters) -> Bool {
        return UserDefaults.standard.bool(forKey: key.rawValue)
    }
    
    public class func setSettingsBundleBoolValue(forKey key: SettingsBundleParameters, value: Bool) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }

    public class func handleChangesIfNeeded() {
        handleLoggerAssistance()
    }

    class func handleLoggerAssistance() {
        let newValue = getSettingsBundleBoolValue(forKey: .loggerAssistance)
        let oldValue = getSettingsBundleLastUsedBoolValue(forKey: .loggerAssistance)
        if newValue != oldValue {
            if newValue == true,
                let urlScheme = APSwiftUtils.appUrlScheme,
                let url = URL(string: "\(urlScheme)://settings?type=\(SettingsBundleParameters.loggerAssistance.rawValue)") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                setSettingsBundleLastUsedBoolValue(forKey: .loggerAssistance, value: newValue)
            }
        }
    }
}

extension SettingsBundleHelper {
    public enum SettingsBundleParametersSavedValues: String {
        case loggerAssistance = "logger_assistance_value"
    }

    public class func getSettingsBundleLastUsedBoolValue(forKey key: SettingsBundleParametersSavedValues) -> Bool {
        return UserDefaults.standard.bool(forKey: key.rawValue)
    }

    class func setSettingsBundleLastUsedBoolValue(forKey key: SettingsBundleParametersSavedValues, value: Bool) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }
}
