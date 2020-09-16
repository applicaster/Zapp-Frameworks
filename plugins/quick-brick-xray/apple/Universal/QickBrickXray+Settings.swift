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
    func prepareSettings() {
        let settingsFromLocalStorage = getLocalStorageSettings()
        guard settingsFromLocalStorage.customSettingsEnabled == true else {
            let settingsParams = getDefaultPluginSettings()
            applyNewSettings(settings: settingsParams)
            return
        }
        applyNewSettings(settings: settingsFromLocalStorage)
    }

    func applyCustomSettings(settings: Settings) {
        saveSettingsToLocalStorage(settings: settings)
        if settings.customSettingsEnabled == false {
            prepareSettings()
        } else {
            applyNewSettings(settings: settings)
        }
    }

    func applyNewSettings(settings: Settings) {
        if currentSettings == nil {
            currentSettings = settings
        } else {
            currentSettings = currentSettings?.merge(highPriority: settings)
        }

        commitSettings()
    }

    func getDefaultPluginSettings() -> Settings {
        var settings = Settings(customSettingsEnabled: false,
                                shortcutEnabled: true,
                                fileLogLevel: configurationHelper.logLevel())
        if isDebugEnvironment == false {
            settings.fileLogLevel = .error
            settings.shortcutEnabled = false
        }
        return settings
    }

    func getLocalStorageSettings() -> Settings {
        var settings = Settings(customSettingsEnabled: false,
                                shortcutEnabled: true,
                                fileLogLevel: configurationHelper.logLevel())

        if let customSettingsEnabledString = FacadeConnector.connector?.storage?.localStorageValue(for: PluginConfigurationKeys.CustomSettingsEnabled,
                                                                                                   namespace: pluginNameSpace),
            let customSettingsEnabled = Bool(customSettingsEnabledString) {
            settings.customSettingsEnabled = customSettingsEnabled
        }

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

        let customSettingsEnabled = settings?.customSettingsEnabled ?? false ? "true" : "false"

        _ = FacadeConnector.connector?.storage?.localStorageSetValue(for: PluginConfigurationKeys.CustomSettingsEnabled,
                                                                     value: customSettingsEnabled,
                                                                     namespace: pluginNameSpace)
    }

    func removeLocalStorageSettings() {
        saveSettingsToLocalStorage(settings: nil)
    }
}
