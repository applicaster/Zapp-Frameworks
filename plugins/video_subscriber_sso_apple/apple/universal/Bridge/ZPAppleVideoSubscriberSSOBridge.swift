//
//  ZPAppleVideoSubscriberSSOBridge.swift
//  ZappAppleVideoSubscriberSSO
//
//  Created by Alex Zchut on 20/03/2020.
//  Copyright © 2020 Applicaster Ltd. All rights reserved.
//

import Foundation
import React
import ZappCore

struct ErrorMessages {
    static let unexpectedError = (code: "0", message: "Unexpected Error, please try again later")
    static let notAuthorized = (code: "1", message: "Not authorized")
    static let canNotSignIn = (code: "2", message: "Can not sign in, please try again later")
}

@objc(AppleVideoSubscriberSSO)
class ZPAppleVideoSubscriberSSOBridge: NSObject, RCTBridgeModule {
    static var appleVideoSubscriberSSO: ZPAppleVideoSubscriberSSO?

    let pluginIdentifier = "video_subscriber_sso_apple"
    var bridge: RCTBridge!

    static func moduleName() -> String! {
        return "AppleVideoSubscriberSSO"
    }

    public class func requiresMainQueueSetup() -> Bool {
        return true
    }

    @objc public func signIn(_ resolver: @escaping RCTPromiseResolveBlock,
                                 rejecter: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            if let videoSubscriber = ZPAppleVideoSubscriberSSOBridge.appleVideoSubscriberSSO {
                videoSubscriber.performSsoOperation { success in
                    resolver(success)
                }
            } else {
                rejecter(ErrorMessages.unexpectedError.code,
                         ErrorMessages.unexpectedError.message, nil)
            }
        }
    }

    @objc public func signOut(_ resolver: @escaping RCTPromiseResolveBlock,
                              rejecter: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            if let videoSubscriber = ZPAppleVideoSubscriberSSOBridge.appleVideoSubscriberSSO {
                videoSubscriber.signOut()
                resolver(true)
            } else {
                rejecter(ErrorMessages.unexpectedError.code,
                         ErrorMessages.unexpectedError.message, nil)
            }
        }
    }

    @objc public func isSignedIn(_ resolver: @escaping RCTPromiseResolveBlock,
                                 rejecter: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            if let videoSubscriber = ZPAppleVideoSubscriberSSOBridge.appleVideoSubscriberSSO {
                videoSubscriber.isSignedIn({ isSignedIn in
                    resolver(isSignedIn)
                })
            } else {
                rejecter(ErrorMessages.unexpectedError.code,
                         ErrorMessages.unexpectedError.message, nil)
            }
        }
    }
}
