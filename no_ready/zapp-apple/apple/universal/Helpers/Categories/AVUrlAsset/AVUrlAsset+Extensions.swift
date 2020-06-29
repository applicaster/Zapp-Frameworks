//
//  CGFloat+Extensions.swift
//  ZappPlugins
//
//  Created by Anton Kononenko on 30/10/2017.
//  Copyright © 2017 Applicaster Ltd. All rights reserved.
//

import Foundation
import AVFoundation

@objc extension AVURLAsset {
    open override func isEqual(_ object: Any?) -> Bool {
        guard let urlAsset = object as? AVURLAsset else {
            return false
        }
        return self.url.absoluteString == urlAsset.url.absoluteString
    }
}
