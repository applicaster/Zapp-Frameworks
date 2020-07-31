//
//  ZPAppleVideoNowPlayingInfo+Observers.swift
//  ZappAppleVideoSubscriberSSO
//
//  Created by Alex Zchut on 22/03/2020.
//  Copyright © 2020 Applicaster Ltd. All rights reserved.
//

import Foundation
import ZappCore

extension ZPAppleVideoSubscriberSSO: PluginAdapterProtocol {
    public var providerName: String {
        return "Apple Video Subscriber SSO"
    }

    public func prepareProvider(_ defaultParams: [String: Any], completion: ((Bool) -> Void)?) {
        completion(success)
        ZPAppleVideoSubscriberSSOBridge.appleSubscriptionSSO = self
 
    }

    public func disable(completion: ((Bool) -> Void)?) {
        ZPAppleVideoSubscriberSSOBridge.appleSubscriptionSSO = nil
        completion?(true)
    }
}
