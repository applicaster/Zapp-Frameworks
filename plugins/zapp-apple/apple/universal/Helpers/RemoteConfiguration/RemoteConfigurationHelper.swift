//
//  RemoteConfigurationHelper.swift
//  ZappApple
//
//  Created by Alex Zchut on 02/05/2021.
//

import Foundation
import ZappCore

class RemoteConfigurationHelper {
    struct Content: Codable {
        let localizations: [String: String]
    }

    public class func update() {
        guard let localizations = retriveData()?.localizations,
              let locale = getLocaleToUse(localizations.keys.sorted()),
              !locale.isEmpty else {
            return
        }
        SessionStorage.sharedInstance.set(key: ZappStorageKeys.languageCode,
                                          value: locale,
                                          namespace: nil)
    }

    class func retriveData() -> RemoteConfigurationHelper.Content? {
        guard let url = LoadingManager().file(type: .remoteConfiguration)?.localURLPath() else {
            return nil
        }

        do {
            let data = try Data(contentsOf: url, options: .mappedIfSafe)
            return try JSONDecoder().decode(RemoteConfigurationHelper.Content.self, from: data)
        } catch {
            return nil
        }
    }

    /// the logic for selecting the locale is as follows:
    /// - if the device is set to a language that is part of the locales declared in Zapp for that app, we use this
    /// - if not, we pick the first locale in the localizations.json
    private class func getLocaleToUse(_ localeKeys: [String]) -> String? {
        let deviceLocale = NSLocale.preferredLanguages.first?.split(separator: "-").first ?? ""
        let matchingLocales = Set(localeKeys).intersection([String(deviceLocale)])

        if matchingLocales.count > 0 {
            return matchingLocales.first
        }

        return localeKeys.first
    }
}
