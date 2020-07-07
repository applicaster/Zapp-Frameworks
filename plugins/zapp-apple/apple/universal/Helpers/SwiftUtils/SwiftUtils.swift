//
//  APSwiftUtils.swift
//  ZappApple
//
//  Created by Anton Kononenko on 21/12/2016.
//  Copyright © 2016 Applicaster Ltd. All rights reserved.
//

import Foundation
import AdSupport

@objc public class APSwiftUtils : NSObject {
    
    /// Detect if simulator enabled
    public static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif
        return isSim
    }()
    
    /**
     This method returns the idfa for this device. This is the advertising it. Nil if don't have one.
     */
    @objc public static func identifierForAdvertising() -> String? {
        // Check whether advertising tracking is enabled
        guard ASIdentifierManager.shared().isAdvertisingTrackingEnabled else {
            return nil
        }
        
        // Get and return IDFA
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
    
}
