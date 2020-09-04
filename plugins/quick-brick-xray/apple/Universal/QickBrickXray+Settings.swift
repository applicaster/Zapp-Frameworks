//
//  QickBrickXray.swift
//  QickBrickXray
//
//  Created by Anton Kononenko on 27/08/2020.
//  Copyright © 2020 Applicaster Ltd. All rights reserved.
//

import LoggerInfo
import Reporter
import UIKit
import XrayLogger
import ZappCore

extension QickBrickXray {
    // Priority List for Settings
    // ConfigrationJSON
    // IS_DEBUB_EnV = false -> Specific rules
    // Setting screen
    // URL Scheme

    func prepareSettings() {
        guard let settingsFromLocalStorage = getLocalStorageSettings() else {
            let settingsParams = getConfigurationJSONSettings().merge(highPriority: getEnvironmentSettings())
            applyNewSettings(settings: settingsParams)
            return
        }
        applyNewSettings(settings: settingsFromLocalStorage)
    }

    func applyNewSettings(settings: Settings) {
        if currentSettings == nil {
            currentSettings = settings
        } else {
            currentSettings = currentSettings?.merge(highPriority: settings)
        }

        saveSettingsToLocalStorage(settings: currentSettings)
        commitSettings()
    }

    func getConfigurationJSONSettings() -> Settings {
        let settings = Settings(fileLogLevel: configurationHelper.logLevel(),
                                reactNativeLogLevel: configurationHelper.RNlogLevel())
        return settings
    }

    func getEnvironmentSettings() -> Settings {
        var settings = Settings()
        if isDebugEnvironment == false {
            settings.fileLogLevel = .error
            settings.reactNativeLogLevel = .error
        }

        return settings
    }

    func getLocalStorageSettings() -> Settings? {
        var settings = Settings()

        if let shortcutEnabledString = FacadeConnector.connector?.storage?.localStorageValue(for: PluginConfigurationKeys.ShortcutEnabled,
                                                                                             namespace: pluginNameSpace),
            let shortcutEnabled = Bool(shortcutEnabledString) {
            settings.shortcutEnabled = shortcutEnabled
        }

        if let fileLogLevelString = FacadeConnector.connector?.storage?.localStorageValue(for: PluginConfigurationKeys.FileLogLevel,
                                                                                          namespace: pluginNameSpace),
            let fileLogLevel = LogLevel.logLevel(fromConfigurationKey: fileLogLevelString) {
            settings.fileLogLevel = fileLogLevel
        }

        if let reactNativeLogLevelString = FacadeConnector.connector?.storage?.localStorageValue(for: PluginConfigurationKeys.ReactNativeLogLevel,
                                                                                                 namespace: pluginNameSpace),
            let reactNativeLogLevel = LogLevel.logLevel(fromConfigurationKey: reactNativeLogLevelString) {
            settings.reactNativeLogLevel = reactNativeLogLevel
        }
        return settings
    }

    func saveSettingsToLocalStorage(settings: Settings?) {
        let shortcutEnabled = settings?.shortcutEnabled ?? false ? "true" : "false"
        _ = FacadeConnector.connector?.storage?.localStorageSetValue(for: PluginConfigurationKeys.ShortcutEnabled,
                                                                     value: shortcutEnabled,
                                                                     namespace: pluginNameSpace)
        _ = FacadeConnector.connector?.storage?.localStorageSetValue(for: PluginConfigurationKeys.FileLogLevel,
                                                                     value: settings?.fileLogLevel?.toConfigurationKey(),
                                                                     namespace: pluginNameSpace)
        _ = FacadeConnector.connector?.storage?.localStorageSetValue(for: PluginConfigurationKeys.ReactNativeLogLevel,
                                                                     value: settings?.reactNativeLogLevel?.toConfigurationKey(),
                                                                     namespace: pluginNameSpace)
    }

    func removeLocalStorageSettings() {
        saveSettingsToLocalStorage(settings: nil)
    }
}
