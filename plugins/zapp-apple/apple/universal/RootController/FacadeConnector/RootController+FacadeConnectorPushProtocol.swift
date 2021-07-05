//
//  RootController+FacadeConnectorPushProtocol.swift
//  ZappApple
//
//  Created by Anton Kononenko on 1/28/20.
//

import Foundation
import ZappCore

extension RootController: FacadeConnectorPushProtocol {
    public func addTagsToDevice(_ tags: [String]?, completion: @escaping (Bool, [String]?) -> Void) {
        pluginsManager.push.addTagsToDevice(tags,
                                            completion: completion)
    }

    public func removeTagsToDevice(_ tags: [String]?, completion: @escaping (Bool, [String]?) -> Void) {
        pluginsManager.push.removeTagsToDevice(tags,
                                               completion: completion)
    }

    public func addTags(_ tags: [String]?, completion: @escaping (Result<[String]?, PushProviderError>) -> Void) {
        pluginsManager.push.addTags(tags,
                                    completion: completion)
    }

    public func removeTags(_ tags: [String]?, completion: @escaping (Result<[String]?, PushProviderError>) -> Void) {
        pluginsManager.push.removeTags(tags,
                                       completion: completion)
    }

    public func getDeviceTags() -> [String: [String]] {
        pluginsManager.push.getDeviceTags()
    }
}
