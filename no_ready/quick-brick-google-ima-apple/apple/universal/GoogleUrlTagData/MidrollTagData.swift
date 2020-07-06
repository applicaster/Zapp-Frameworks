//
//  MidrollTagData.swift
//  ZappGoogleInteractiveMediaAds
//
//  Created by Anton Kononenko on 12/27/19.
//  Copyright © 2019 Anton Kononenko. All rights reserved.
//

import Foundation

struct MidrollTagData {
    var timeOffset: TimeInterval
    var url: String

    init(url: String, timeOffset: TimeInterval) {
        self.url = url
        self.timeOffset = timeOffset
    }
}
