//
//  ReactNativeManager+LocalizationsUtils.swift
//  QuickBrickApple
//
//  Created by François Roland on 23/09/2020.
//

import Foundation
import React
import ZappCore

struct RemoteConfigurationJson: Codable {
    let localizations: [String: String]
}


extension ReactNativeManager {
    public func setRightToLeftFlag(completion: @escaping () -> Void) {
        
        if let remoteConfigurationUrl = FacadeConnector.connector?.storage?.sessionStorageValue(for: "remote_configuration_url", namespace: "applicaster.v2") {
            loadJson(remoteConfigurationUrl) { result in
                switch result {
                case .success(let data):
                    if let locales = self.parseJson(jsonData: data)?.localizations {
                        let localeToUse = self.getLocaleToUse(locales.keys.sorted())
                        self.setRTL(RTLLocales.includes(locale: localeToUse))
                        completion()
                    }

                case .failure(let error):
                    self.logger?.errorLog(message: ReactNativeManagerLogs.setRightToLeftFlagError.message,
                                     category: ReactNativeManagerLogs.setRightToLeftFlagError.category,
                                     data: ["error": error.localizedDescription])
                    print(error)
                }
            }
        }
    }
    
    private func setRTL(_ isRTL: Bool) {
        if let reactI18Util = RCTI18nUtil.sharedInstance() {
            reactI18Util.allowRTL(isRTL)
            reactI18Util.forceRTL(isRTL)
        }
    }
    
    /// the logic for selecting the locale is as follows:
    /// - if the device is set to a language that is part of the locales declared in Zapp for that app, we use this
    /// - if not, we pick the first locale in the localizations.json
    
    private func getLocaleToUse(_ localeKeys: [String]) -> String {
        let deviceLocales = NSLocale.preferredLanguages.map { String($0.split(separator: "-").first ?? "") }
        let matchingLocales = Set(localeKeys).intersection(deviceLocales)
        
        if matchingLocales.count > 0 {
            return matchingLocales.first ?? ""
        }
        
        return localeKeys.first ?? ""
    }
    
    private func parseJson(jsonData: Data) -> RemoteConfigurationJson? {
        do {
            let decodedData = try JSONDecoder().decode(RemoteConfigurationJson.self, from: jsonData)
            
            return decodedData
        } catch {
            return nil
        }
    }
    
    private func loadJson(_ jsonUrl: String, completion: @escaping (Result<Data, Error>) -> Void) {
        if let url = URL(string: jsonUrl) {
            let urlSession = URLSession(configuration: .default).dataTask(with: url) { (data, response, error) in
                if let error = error {
                    self.logger?.errorLog(message: ReactNativeManagerLogs.failedToLoadJson.message,
                                     category: ReactNativeManagerLogs.failedToLoadJson.category,
                                     data: ["url": jsonUrl,
                                            "error": error.localizedDescription])
                    completion(.failure(error))
                }
                
                if let data = data {
                    completion(.success(data))
                }
            }
            
            urlSession.resume()
        }
    }
}
