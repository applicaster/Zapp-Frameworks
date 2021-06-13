//
//  OneTrustCmp+ReactBridge.swift
//  ZappCmpOneTrust
//
//  Created by Alex Zchut on 13/06/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import OneTrust
import Foundation

extension OneTrustCmp {
    public func showPreferences() -> (success: Bool, errorDescription: String? ) {
        guard OneTrust.shared.isReady() == true else {
            return (false, "OneTrust is not ready")
        }

        OneTrust.shared.showPreferences()
        
        return (true, nil)
    }
    
    public func showNotice() -> (success: Bool, errorDescription: String? ) {
        guard OneTrust.shared.isReady() == true else {
            return (false, "OneTrust is not ready")
        }
        
        OneTrust.shared.showNotice()
        
        return (true, nil)
    }
}
