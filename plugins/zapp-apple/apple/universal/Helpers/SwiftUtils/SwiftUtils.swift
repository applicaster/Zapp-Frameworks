//
//  APSwiftUtils.swift
//  ZappApple
//
//  Created by Anton Kononenko on 21/12/2016.
//  Copyright © 2016 Applicaster Ltd. All rights reserved.
//

import Foundation

@objc public class APSwiftUtils: NSObject {
    /// Detect if simulator enabled
    public static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif
        return isSim
    }()

    static var appUrlScheme: String? = {
        guard let arrUrlTypes = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String: AnyObject]],
              let arrUrlSchemes = arrUrlTypes.first?["CFBundleURLSchemes"] as? [AnyObject],
              let urlScheme = arrUrlSchemes.first as? String else {
            return nil
        }

        return urlScheme
    }()
}
