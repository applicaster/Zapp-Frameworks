//
//  PipesDataModelHelperExtensions.swift
//  ZappPlugins
//
//  Created by Anton Kononenko on 8/27/19.
//  Copyright © 2019 Applicaster LTD. All rights reserved.
//

import Foundation

public struct PipesDataModelHelperExtensions {
    public let extensionsObject: [AnyHashable: Any]?
    public init(extensionsDict: [AnyHashable: Any]?) {
        extensionsObject = extensionsDict
    }

    public var isFree: Bool {
        var retVal = true
        if let free = extensionsObject?["free"] as? Bool {
            retVal = free
        } else if let free = extensionsObject?["free"] as? String {
            retVal = free == "true" ? true : false
        }
        return retVal
    }

    public var isLive: Bool {
        var retVal = false
        if let free = extensionsObject?["isLive"] as? Bool {
            retVal = free
        } else if let free = extensionsObject?["isLive"] as? String {
            retVal = free == "true" ? true : false
        }
        return retVal
    }
}
