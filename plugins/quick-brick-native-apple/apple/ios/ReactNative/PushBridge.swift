//
//  PushBridge.swift
//  QuickBrickApple
//
//  Created by Anton Kononenko on 1/27/20.
//

import Foundation
import React
import ZappCore

@objc(PushBridge)
class PushBridge: NSObject, RCTBridgeModule {
    let addTagsErrorCode = "error_add_tags"
    let removeTagsErrorCode = "error_remove_tags"
    let getTagsErrorCode = "error_get_tags"

    static func moduleName() -> String! {
        return "PushBridge"
    }

    public class func requiresMainQueueSetup() -> Bool {
        return true
    }

    /// prefered thread on which to run this native module
    @objc public var methodQueue: DispatchQueue {
        return DispatchQueue.main
    }

    /// Subscribe the push provider with the tags passed as parameters
    ///
    /// - Parameters:
    ///   - tags: tags to subscribe
    ///   - resolver: resolver when everything succeed
    ///   - rejecter: rejecter when something fails
    @objc func registerTags(_ tags: [String]?,
                            resolver: @escaping RCTPromiseResolveBlock,
                            rejecter: @escaping RCTPromiseRejectBlock) {
        
        FacadeConnector.connector?.push?.addTags(tags, completion: { result in
            switch result {
            case .success(_):
                resolver(true)
            case let .failure(error):
                rejecter(self.addTagsErrorCode, error.description, nil)
            }
        })

    }

    /// Remove the tags from the push provider
    ///
    /// - Parameters:
    ///   - tags: tags to remove
    ///   - resolver: resolver when everything succeed
    ///   - rejecter: rejecter when something fails
    @objc func unregisterTags(_ tags: [String]?,
                              resolver: @escaping RCTPromiseResolveBlock,
                              rejecter: @escaping RCTPromiseRejectBlock) {

        FacadeConnector.connector?.push?.removeTags(tags, completion: { result in
            switch result {
            case .success(_):
                resolver(true)
            case let .failure(error):
                rejecter(self.removeTagsErrorCode, error.localizedDescription, nil)
            }
        })
    }

    /// Get the tags which the push provider has been suscribed to
    ///
    /// - Parameters:
    ///   - resolver: resolver when everything succeed
    @objc func getRegisteredTags(_ resolver: @escaping RCTPromiseResolveBlock,
                                 rejecter: @escaping RCTPromiseResolveBlock) {
        let tags = FacadeConnector.connector?.push?.getDeviceTags()
        resolver(tags)
    }
}
