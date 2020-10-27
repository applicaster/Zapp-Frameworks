//
//
//  ZappAnalyticsPlugins
//
//  Created by Elad Ben david on 12/02/2017.
//  Copyright © 2017 Applicaster Ltd. All rights reserved.
//


/*!
 * @type              String+Shortcuts.swift
 * @abstract          Extand string functionaly
 * @additional tag    Alphanumeric
 */


import Foundation


extension String {
    public var isNotAlphanumeric: Bool {
        return  isEmpty || range(of: "[^a-zA-Z0-9{_}]", options: .regularExpression) != nil
    }
    
    public var getFirstCharacter: String? {
        guard 0 < self.count else { return "" }
        let idx = index(startIndex, offsetBy: 0)
        return String(self[idx...idx])
    }
    
}
