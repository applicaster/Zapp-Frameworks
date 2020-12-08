//
//  ZPSessionStorageIdfa.swift
//  ZappSessionStorageIdfa
//
//  Created by Alex Zchut on 01/12/2020.
//  Copyright © 2020 Applicaster Ltd. All rights reserved.
//

import AdSupport
import ZappCore

@objc public class ZPSessionStorageIdfa: NSObject, GeneralProviderProtocol {
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

extension ZPSessionStorageIdfa: AppLoadingHookProtocol {
    public func executeOnApplicationReady(displayViewController: UIViewController?, completion: (() -> Void)?) {
        if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
            let idfaString = ASIdentifierManager.shared().advertisingIdentifier.uuidString

            _ = FacadeConnector.connector?.storage?.sessionStorageSetValue(for: "idfa",
                                                                           value: idfaString,
                                                                           namespace: nil)

            _ = FacadeConnector.connector?.storage?.sessionStorageSetValue(for: "advertisingIdentifier",
                                                                           value: idfaString,
                                                                           namespace: nil)
        }

        completion?()
    }
}