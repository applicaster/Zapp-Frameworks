//
//  PushPluginManager+FacadeConnectorPushProtocol.swift
//  ZappApple
//
//  Created by Anton Kononenko on 1/27/20.
//

import Foundation
import ZappCore

extension PushPluginsManager: FacadeConnectorPushProtocol {
    @objc public func addTagsToDevice(_ tags: [String]?,
                               completion: @escaping (_ success: Bool, _ tags: [String]?) -> Void) {
        var counter = _providers.count
        var completionSuccess = true
        _providers.forEach { providerDict in
            let provider = providerDict.value
            if provider.addTagsToDevice != nil {
                provider.addTagsToDevice?(tags, completion: { success, tags in
                    counter -= 1
                    if completionSuccess == true && success == false {
                        completionSuccess = success
                    }
                    if counter == 0 {
                        completion(true, tags)
                    }
                })
            } else {
                counter -= 1
            }
        }
    }

    @objc public func removeTagsToDevice(_ tags: [String]?,
                                  completion: @escaping (_ success: Bool, _ tags: [String]?) -> Void) {
        var counter = _providers.count
        var completionSuccess = true
        _providers.forEach { providerDict in
            let provider = providerDict.value
            if provider.removeTagsToDevice != nil {
                provider.removeTagsToDevice?(tags, completion: { success, tags in
                    counter -= 1
                    if completionSuccess == true && success == false {
                        completionSuccess = success
                    }
                    if counter == 0 {
                        completion(true, tags)
                    }
                })
            } else {
                counter -= 1
            }
        }
    }

    @objc public func getDeviceTags() -> [String: [String]] {
        var retVal: [String: [String]] = [:]
        _providers.forEach { providerDict in
            let provider = providerDict.value
            if let deviceTags = provider.getDeviceTags,
                let pluginIdentifier = provider.model?.identifier {
                retVal[pluginIdentifier] = deviceTags()
            }
        }
        return retVal
    }
}
