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
        guard let tags = tags else {
            rejecter(addTagsErrorCode, "The tags couldn't be registered. Please check that the tags don't exist already.", nil)
            return
        }
        FacadeConnector.connector?.push?.addTagsToDevice(tags, completion: { success, _ in
            if success {
                resolver(true)
            } else {
                rejecter(self.addTagsErrorCode, "The tags couldn't be registered. Please check that the tags don't exist already.", nil)
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
        guard let tags = tags else {
            rejecter(removeTagsErrorCode,
                     "The tags couldn't be unregistered. Please check that the tags exist.", nil)
            return
        }
        FacadeConnector.connector?.push?.removeTagsToDevice(tags, completion: { success, _ in
            if success {
                resolver(true)
            } else {
                rejecter(self.removeTagsErrorCode, "The tags couldn't be unregistered. Please check that the tags exist.", nil)
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
