//
//  PipesDataModelHelperContent.swift
//  ZappPlugins
//
//  Created by Anton Kononenko on 8/27/19.
//  Copyright © 2019 Applicaster LTD. All rights reserved.
//

import Foundation

public struct PipesDataModelHelperContent {
    public let contentObject: [AnyHashable: String]?
    public init(contentDict: [AnyHashable: String]?) {
        contentObject = contentDict
    }

    public var type: String? {
        return contentObject?["type"]
    }

    public var content: String? {
        return contentObject?["content"]
    }

    public var contesrcnt: String? {
        return contentObject?["src"]
    }
}
