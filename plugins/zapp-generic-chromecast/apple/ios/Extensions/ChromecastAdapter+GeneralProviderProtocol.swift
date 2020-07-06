//
//  ChromecastAdapter+GeneralProviderProtocol.swift
//  ZappGeneralPluginChromecast
//
//  Created by Alex Zchut on 29/03/2020.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import ZappCore

extension ChromecastAdapter : GeneralProviderProtocol {
    open func disable(completion: ((Bool) -> Void)?) {
        completion?(true)
    }
    
    open func prepareProvider(_ defaultParams: [String : Any], completion: ((Bool) -> Void)?) {

        var prepared = false
        if !self.initialized {
            prepared = self.prepareChromecastForUse()
        }
        
        updateManagerState(enabled: prepared,
                           initialized: true)
        
        completion?(true)
    }
    
    open var providerName: String {
        return "Chromecast"
    }
}
