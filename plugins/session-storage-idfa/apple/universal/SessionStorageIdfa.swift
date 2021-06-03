//
//  SessionStorageIdfa.swift
//  ZappSessionStorageIdfa
//
//  Created by Alex Zchut on 01/12/2020.
//  Copyright © 2020 Applicaster Ltd. All rights reserved.
//

import AdSupport
import ZappCore

@objc public class SessionStorageIdfa: NSObject, GeneralProviderProtocol {
    public var model: ZPPluginModel?

    public required init(pluginModel: ZPPluginModel) {
        model = pluginModel
    }

    public var providerName: String {
        return String(describing: Self.self)
    }

    public func prepareProvider(_ defaultParams: [String: Any],
                                completion: ((_ isReady: Bool) -> Void)?) {
        completion?(true)
    }

    public func disable(completion: ((Bool) -> Void)?) {
        completion?(true)
    }
}
