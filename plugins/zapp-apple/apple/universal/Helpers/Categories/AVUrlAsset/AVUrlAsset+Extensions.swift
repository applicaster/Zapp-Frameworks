//
//  CGFloat+Extensions.swift
//  ZappPlugins
//
//  Created by Anton Kononenko on 30/10/2017.
//  Copyright © 2017 Applicaster Ltd. All rights reserved.
//

import AVFoundation
import Foundation

@objc extension AVURLAsset {
    override open func isEqual(_ object: Any?) -> Bool {
        guard let urlAsset = object as? AVURLAsset else {
            return false
        }
        return url.absoluteString == urlAsset.url.absoluteString
    }
}
