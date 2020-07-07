//
//  UIApplication+Extension.swift
//  ZappPlugins
//
//  Created by Anton Kononenko on 30/05/2018.
//  Copyright © 2018 Applicaster LTD. All rights reserved.
//

import Foundation
import UIKit

public extension UIApplication {
    
    @objc class func bundleName() -> String {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as! String

    }
    @objc class func appVersion() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }
    
    @objc class func appBuild() -> String {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? ""
    }
    
    @objc class func versionBuild() -> String {
        let version = appVersion(), build = appBuild()
        
        return version == build ? "v\(version)" : "v\(version)(\(build))"
    }
    
    @objc class func bundleVersion() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
    }
}

