//
//  String+Additions.swift
//  ZappAnalyticsPluginGAtvOS
//
//  Created by Anton Kononenko on 10/17/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import Foundation

public extension String {
    static func isNotEmptyOrWhitespace(_ obj: String?) -> Bool {
        return obj?.isEmptyOrWhitespace() == false
    }

    func isEmptyOrWhitespace() -> Bool {
        return trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
    }
}
