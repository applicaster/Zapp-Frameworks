//
//  ZPSessionStorageIdfa.swift
//  ZappSessionStorageIdfa
//
//  Created by Alex Zchut on 11/08/2020.
//  Copyright © 2020 Applicaster Ltd. All rights reserved.
//

import ZappPlugins
import AdSupport

@objc public class ZPSessionStorageIdfa : NSObject {
    public var model: ZPPluginModel?
    public var configurationJSON: NSDictionary?

    public required override init() {
        super.init()
    }
    
    public required init(pluginModel: ZPPluginModel) {
        super.init()
        self.model = pluginModel
    }
        
    public required init(configurationJSON: NSDictionary?) {
        super.init()
        self.configurationJSON = configurationJSON
    }
}

extension ZPSessionStorageIdfa: ZPAppLoadingHookProtocol {
    @objc open func executeOnApplicationReady(displayViewController: UIViewController?, completion: (() -> Void)?) {
        
        // Check whether advertising tracking is enabled
        if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
            let idfaString = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            
            _ = ZAAppConnector.sharedInstance().storageDelegate?.sessionStorageSetValue(for: "idfa",
                                                                                        value: idfaString,
                                                                                        namespace: nil)
            
            _ = ZAAppConnector.sharedInstance().storageDelegate?.sessionStorageSetValue(for: "advertisingIdentifier",
                                                                                        value: idfaString,
                                                                                        namespace: nil)
        }
        
        completion?()
    }
}

extension ZPSessionStorageIdfa: ZPGeneralPluginProtocol {
    @objc open func activate(options: [AnyHashable: Any]?) {
        //leaving empty as it is default implementation
    }
    @objc open func activate(object: NSObject?) {
        activate(object: nil, completion: nil)
    }
    @objc open func activate() {
        activate(object: nil, completion: nil)
    }
    
    @objc open func deactivate(completion: ((Bool) -> Void)?) {
        //leaving empty as it is default implementation
        
    }
    
    @objc open func deactivateAll(completion: ((Bool) -> Void)?) {
        //leaving empty as it is default implementation
    }
    
    @objc open func activate(object: NSObject?, completion: ((NSObject?) -> Void)?) {
        completion?(nil)
    }
    
    
    open func prepareProvider(_ defaultParams: [String : Any], completion: ((Bool) -> Void)?) {
        completion?(true)
    }
    
    open func disable(completion: ((Bool) -> Void)?) {
        completion?(true)
    }

    open var providerName: String {
        return String(describing: Self.self)
    }
    
}
