//
//  FeaturesCustomization.swift
//  ZappApple
//
//  Created by Anton Kononenko on 10/8/19.
//  Copyright © 2019 Anton Kononenko. All rights reserved.
//

import Foundation

public class FeaturesCustomization {
    static var featuresCustomizationDict:[AnyHashable:Any]? = getPlist()
    
    class func getPlist() -> [AnyHashable:Any]? {
        guard let path = Bundle.main.path(forResource: DataManager.ApplicationFiles.featureCustomization,
                                          ofType: DataManager.DataKeysExtensions.plist),
            
        let data = FileManager.default.contents(atPath: path)  else {
            return nil
        }

        return (try? PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: nil)) as? [AnyHashable:Any]
    }
    
    class func msAppCenterAppSecret() -> String? {
        return featuresCustomizationDict?[FeaturesCusimizationConsts.MSAppCenterAppSecret] as? String
    }
 
    public class func s3Hostname() -> String {
        guard let hostname = featuresCustomizationDict?[FeaturesCusimizationConsts.S3Hostname] as? String,
            hostname.isEmpty == false else {
            return "assets-secure.applicaster.com"
        }
        return hostname
    }
}

