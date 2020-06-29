//
//  PipesDataModelHelperMediaItem.swift
//  ZappPlugins
//
//  Created by Anton Kononenko on 8/27/19.
//  Copyright © 2019 Applicaster LTD. All rights reserved.
//

import Foundation

public struct PipesDataModelHelperMediaItem {
    public let src: String
    public let key: String

    public init(key: String,
                src: String) {
        self.key = key
        self.src = src
    }
}
