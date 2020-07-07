//
//  String+APAdditions.swift
//  ZappPlugins
//
//  Created by Alex Zchut on 03/07/2017.
//  Copyright © 2017 Applicaster Ltd. All rights reserved.
//

import Foundation
import UIKit
import CommonCrypto

public extension String {
    func toMd5hash() -> String {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: length)

        if let d = self.data(using: .utf8) {
            _ = d.withUnsafeBytes { body -> String in
                CC_MD5(body.baseAddress, CC_LONG(d.count), &digest)

                return ""
            }
        }

        return (0 ..< length).reduce("") {
            $0 + String(format: "%02x", digest[$1])
        }
    }

    static func isNotEmptyOrWhitespace(_ obj: String?) -> Bool {
        return obj?.isEmptyOrWhitespace() == false
    }

    func isEmptyOrWhitespace() -> Bool {
        return trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
    }

    // can not use this function because self can be nil and the result will be nil and not bool
    @available(*, deprecated, message: "Use String.isNotEmptyOrWhitespace class function instead")
    func isNotEmptyOrWhitespace() -> Bool {
        return !isEmptyOrWhitespace()
    }

    func boolValue() -> Bool {
        let trueValues = ["true", "yes", "1"]
        return trueValues.contains(lowercased())
    }

    // https://gist.github.com/albertbori/0faf7de867d96eb83591
    func replace(_ target: String, withString: String) -> String {
        return replacingOccurrences(of: target,
                                    with: withString,
                                    options: NSString.CompareOptions.literal,
                                    range: nil)
    }

    var isDigits: Bool {
        // The inverted set of .decimalDigits is every character minus digits
        let nonDigits = CharacterSet.decimalDigits.inverted
        return rangeOfCharacter(from: nonDigits) == nil
    }

    static func tryAddHost(to urlString: String) -> String? {
        let urlWithHost = "https://" + urlString
        if let url = URL(string: urlString),
            UIApplication.shared.canOpenURL(url) == true {
            return urlString
        } else if let url = URL(string: urlWithHost),
            UIApplication.shared.canOpenURL(url) == true {
            return urlWithHost
        }

        return nil
    }

    var isURLScheme: Bool {
        let url = URL(string: self)
        return url?.scheme != nil && url?.host != nil
    }

    // Modify zapp style color string #aarrggbb -> rrggbbaa
    func normalizedZappColorString() -> String {
        // Make sure color string is of the expected length and NOT empty string from Zapp
        if count == 9 {
            let modifiedColor = dropFirst().uppercased()
            let colorIndex = String.Index(utf16Offset: 2, in: modifiedColor)
            let correctedColorValue = String(modifiedColor.suffix(from: colorIndex) + modifiedColor.prefix(upTo: colorIndex))
            return correctedColorValue
        } else {
            return self
        }
    }
}
