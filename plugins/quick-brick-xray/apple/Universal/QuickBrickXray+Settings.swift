//
//  QuickBrickXray.swift
//  QuickBrickXray
//
//  Created by Anton Kononenko on 27/08/2020.
//  Copyright © 2020 Applicaster Ltd. All rights reserved.
//

import LoggerInfo
import Reporter
import UIKit
import XrayLogger
import ZappCore

extension QuickBrickXray {
    func prepareSettings() {
        let settingsFromLocalStorage = getLocalStorageSettings()
        guard settingsFromLocalStorage.customSettingsEnabled == true else {
            let settingsParams = getDefaultPluginSettings()
            applyNewSettings(settings: settingsParams)
            return
        }

        if settingsFromLocalStorage.isCustomSettingsExpired {
            applyCustomSettings(settings: settingsFromLocalStorage)

        } else {
            applyNewSettings(settings: settingsFromLocalStorage)
        }
    }

    func applyCustomSettings(settings: Settings) {
        var newSettings = settings

        if newSettings.isCustomSettingsExpired == true {
            newSettings.customSettingsEnabled = false
        }

        saveSettingsToLocalStorage(settings: newSettings)
        if newSettings.customSettingsEnabled == false {
            prepareSettings()
        } else {
            applyNewSettings(settings: newSettings)
        }
    }

    func applyNewSettings(settings: Settings) {
        currentSettings = settings
        commitSettings()
    }

    func getDefaultPluginSettings() -> Settings {
        var settings = Settings(customSettingsEnabled: false,
                                shortcutEnabled: true,
                                fileLogLevel: configurationHelper.logLevel())
        if isDebugEnvironment == false {
            settings.fileLogLevel = .error
            settings.shortcutEnabled = false
            settings.showXrayFloatingButtonEnabled = false
        }
        return settings
    }

    func getLocalStorageSettings() -> Settings {
        var settings = Settings(customSettingsEnabled: false,
                                shortcutEnabled: true,
                                fileLogLevel: nil)

        if let customSettingsEnabledString = FacadeConnector.connector?.storage?.localStorageValue(for: PluginConfigurationKeys.CustomSettingsEnabled,
                                                                                                   namespace: pluginNameSpace),
            let customSettingsEnabled = Bool(customSettingsEnabledString) {
            settings.customSettingsEnabled = customSettingsEnabled
        }

        if let customSettingsOffsetToDisableString = FacadeConnector.connector?.storage?.localStorageValue(for: PluginConfigurationKeys.CustomSettingsOffsetToDisable,
                                                                                                           namespace: pluginNameSpace),
            let customSettingsOffsetToDisable = TimeInterval(customSettingsOffsetToDisableString) {
            settings.customSettingsOffsetToDisable = Date(timeIntervalSince1970: customSettingsOffsetToDisable)
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

        if let showXrayFloatingButtonEnabledString = FacadeConnector.connector?.storage?.localStorageValue(for: PluginConfigurationKeys.ShowXrayFloatingButtonEnabled,
                                                                                                           namespace: pluginNameSpace),
            let showXrayFloatingButtonEnabled = Bool(showXrayFloatingButtonEnabledString) {
            settings.showXrayFloatingButtonEnabled = showXrayFloatingButtonEnabled
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

        if settings?.customSettingsEnabled == true,
           let offsetDate = settings?.customSettingsOffsetToDisable {
            let offsetDateTimeInterval = offsetDate.timeIntervalSince1970
            _ = FacadeConnector.connector?.storage?.localStorageSetValue(for: PluginConfigurationKeys.CustomSettingsOffsetToDisable,
                                                                         value: String(offsetDateTimeInterval),
                                                                         namespace: pluginNameSpace)
        } else {
            _ = FacadeConnector.connector?.storage?.localStorageRemoveValue(for: PluginConfigurationKeys.CustomSettingsOffsetToDisable,
                                                                            namespace: pluginNameSpace)
        }

        let showXrayFloatingButtonEnabled = settings?.showXrayFloatingButtonEnabled ?? false ? "true" : "false"
        _ = FacadeConnector.connector?.storage?.localStorageSetValue(for: PluginConfigurationKeys.ShowXrayFloatingButtonEnabled,
                                                                     value: showXrayFloatingButtonEnabled,
                                                                     namespace: pluginNameSpace)
    }

    func removeLocalStorageSettings() {
        saveSettingsToLocalStorage(settings: nil)
    }
}
