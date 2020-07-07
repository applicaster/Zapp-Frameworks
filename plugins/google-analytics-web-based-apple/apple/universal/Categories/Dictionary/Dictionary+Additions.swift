//
//  Dictionary+Additions.swift
//  ZappAnalyticsPluginGAtvOS
//
//  Created by Anton Kononenko on 10/17/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import CoreGraphics
import Foundation

public extension Dictionary {
    func merge(_ dict: Dictionary<Key, Value>) -> Dictionary<Key, Value> {
        var mutableCopy = self
        for (key, value) in dict {
            // If both dictionaries have a value for same key, the value of the other dictionary is used.
            mutableCopy[key] = value
        }
        return mutableCopy
    }
}
