//
//  PushPluginManager+FacadeConnectorPushProtocol.swift
//  ZappApple
//
//  Created by Anton Kononenko on 1/27/20.
//

import Foundation
import ZappCore

extension PushPluginsManager: FacadeConnectorPushProtocol {

    public func addTagsToDevice(_ tags: [String]?,
                                completion: @escaping (_ success: Bool, _ tags: [String]?) -> Void) {
        addTags(tags) { result in
            switch result {
            case let .success(tags):
                completion(true, tags)
            case .failure:
                completion(false, tags)
            }
        }
    }

    public func addTags(_ tags: [String]?,
                        completion: @escaping (Result<[String]?, PushProviderError>) -> Void) {

        guard UIApplication.shared.isRegisteredForRemoteNotifications == true else {
            completion(.failure(.failedToAddTags0NotRegisteredForRemoteNotifications))
            return
        }
        
        guard let tags = tags, tags.count > 0 else {
            completion(.failure(.failedToAddTags0NoTagsToRegister))
            return
        }

        var counter = _providers.count
        guard counter > 0 else {
            completion(.failure(.failedToAddTags0NoPushProvidersAvailable))
            return
        }
        
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
                        completion(.success(tags))
                    }
                })
            } else {
                counter -= 1
            }
        }
    }

    public func removeTagsToDevice(_ tags: [String]?,
                                   completion: @escaping (_ success: Bool, _ tags: [String]?) -> Void) {
        removeTags(tags) { result in
            switch result {
            case let .success(tags):
                completion(true, tags)
            case .failure:
                completion(false, tags)
            }
        }
    }

    public func removeTags(_ tags: [String]?,
                           completion: @escaping (Result<[String]?, PushProviderError>) -> Void) {
        
        guard UIApplication.shared.isRegisteredForRemoteNotifications == true else {
            completion(.failure(.failedToRemoveTags0NotRegisteredForRemoteNotifications))
            return
        }
        
        guard let tags = tags, tags.count > 0 else {
            completion(.failure(.failedToRemoveTags0NoTagsToRemove))
            return
        }
        
        var counter = _providers.count
        guard counter > 0 else {
            completion(.failure(.failedToRemoveTags0NoPushProvidersAvailable))
            return
        }

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
                        completion(.success(tags))
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
