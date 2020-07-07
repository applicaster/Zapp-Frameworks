//
//  CustomDemensionMappingHelper.swift
//  ZappAnalyticsPluginGAtvOS
//
//  Created by Anton Kononenko on 1/16/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import Foundation

class CustomDemensionMappingHelper {
    /// File Name of the Custom Dimension plist
    static let mappingFileName = "CustomDimensionMapping"
    static let fileExension = "plist"

    /// Array of Mapping items for Custom Dimension mapping
    static var mappingArray: [String] = {
        retrieveMappingArray()
    }()

    /// Load Custom Dimension mapping data from the plist
    ///
    /// - Returns: Array of Custom Dimension items
    private class func retrieveMappingArray() -> [String] {
        let bundle = Bundle(for: CustomDemensionMappingHelper.self)
        if let url = bundle.url(forResource: mappingFileName,
                                withExtension: fileExension) {
            if let cdMappingArray = NSArray(contentsOf: url) as? [String] {
                return cdMappingArray
            }
        }
        return []
    }

    /// Transfer Mapping index to Custom Dimension. We need math index of the item for mapping.
    ///
    /// - Parameter mappingIndex: Current Index of the mapping array.
    /// - Returns: Math Index of the Custom Dimension `mappingIndex + 1`
    private class func customDemensionIndex(mappingIndex: Int) -> Int? {
        return mappingIndex >= 0 ? mappingIndex + 1 : nil
    }

    /// Cast dictionary to [String:String].
    ///
    /// - Parameter customParamenters: custom parameters to cast
    /// - Returns: If can not cust or wrong format return empty object
    private class func castDictionary(customParamenters: [String: Any]?) -> [String: String] {
        var retVal: [String: String] = [:]

        if let customParamenters = customParamenters as? [String: String],
            customParamenters.count > 0 {
            retVal = customParamenters
        }
        return retVal
    }

    /// Add Custom Dimension parameters to custom parameters, comparing with mapping  items
    ///
    /// - Parameter customParamenters: original custom parameters
    /// - Returns: original custom parameters in case no custom dimension founded otherwise updated dictionary
    class func paramsForCustomDemensions(customParamenters: [String: Any]?) -> [String: String] {
        let castedCustomParams = castDictionary(customParamenters: customParamenters)
        var retVal: [String: String] = [:]
        for (key, value) in castedCustomParams {
            if let index = mappingArray.firstIndex(of: key),
                let customDemensionIndex = customDemensionIndex(mappingIndex: index) {
                retVal[MeasurementProtocolKeys.All.customDimension + "\(customDemensionIndex)"] = value
            }
        }
        return retVal
    }
}
