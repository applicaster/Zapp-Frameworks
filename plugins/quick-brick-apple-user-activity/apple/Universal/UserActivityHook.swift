//
//  UserActivityHandler.swift
//  AppleUserActivity
//
//  Created by Alex Zchut on 02/11/2020.
//  Copyright © 2020 Applicaster Ltd. All rights reserved.
//

import UIKit
import ZappCore

public class UserActivityHandler: NSObject, GeneralProviderProtocol {
    public var model: ZPPluginModel?

    public required init(pluginModel: ZPPluginModel) {
        model = pluginModel
    }
    
    public var providerName: String {
        "AppleUserActivity"
    }

    public func prepareProvider(_ defaultParams: [String: Any],
                                completion: ((Bool) -> Void)?) {
        completion?(true)
    }
    
    public func disable(completion: ((Bool) -> Void)?) {
        completion?(true)
    }
}
