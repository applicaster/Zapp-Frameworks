//
//  DidomiCMP+ReactBridge.swift
//  ZappCMPDidomi
//
//  Created by Alex Zchut on 29/03/2021.
//

import Didomi
import Foundation

extension DidomiCMP {
    public func showPreferences() -> (success: Bool, errorDescription: String? ) {
        guard Didomi.shared.isReady() == true else {
            return (false, "Didomi is not ready")
        }

        Didomi.shared.showPreferences()
        
        return (true, nil)
    }
    
    public func showNotice() -> (success: Bool, errorDescription: String? ) {
        guard Didomi.shared.isReady() == true else {
            return (false, "Didomi is not ready")
        }
        
        Didomi.shared.showNotice()
        
        return (true, nil)
    }
}
