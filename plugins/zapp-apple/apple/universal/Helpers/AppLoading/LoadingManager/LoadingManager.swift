//
//  LoadingManager.swift
//  ZappApple
//
//  Created by Anton Kononenko on 11/21/18.
//  Copyright © 2018 Applicaster LTD. All rights reserved.
//

import Foundation
import ZappCore

enum LoadingLoaderTypes {
    case plugins
    case styles
    case remoteConfiguration
}

class LoadingManager {
    lazy var plugins: APFile? = {
        if let pluginConfigurationUrl = SessionStorage.sharedInstance.get(key: ZappStorageKeys.pluginConfigurationUrl,
                                                                          namespace: nil) {
            return fileForUrlString(urlString: pluginConfigurationUrl)
        }
        return nil
    }()

    lazy var styles: APFile? = {
        if let stylesUrl = SessionStorage.sharedInstance.get(key: ZappStorageKeys.stylesUrl,
                                                             namespace: nil) {
            return fileForUrlString(urlString: stylesUrl)
        }
        return nil
    }()
    
    lazy var remoteConfiguration: APFile? = {
        if let remoteConfigurationUrl = SessionStorage.sharedInstance.get(key: ZappStorageKeys.remoteConfigurationUrl,
                                                             namespace: nil) {
            return fileForUrlString(urlString: remoteConfigurationUrl)
        }
        return nil
    }()

    func fileForUrlString(urlString: String) -> APFile? {
        guard String.isNotEmptyOrWhitespace(urlString) == true,
              URL(string: urlString) != nil else {
            return nil
        }
        let hash = urlString.toMd5hash()
        let fileName = hash + ".json"
        return APFile(filename: fileName,
                      url: urlString)
    }

    func loadFile(type: LoadingLoaderTypes,
                  completion: @escaping (_ success: Bool) -> Void) {
        if let fileToLoad = file(type: type) {
            APCacheManager.shared.download(file: fileToLoad) { success in
                if success == false,
                   fileToLoad.isInLocalStorage() {
                    completion(true)
                } else {
                    completion(success)
                }
            }
        }
    }

    func file(type: LoadingLoaderTypes) -> APFile? {
        switch type {
        case .plugins:
            return plugins
        case .styles:
            return styles
        case .remoteConfiguration:
            return remoteConfiguration
        }
    }
}
