//
//  GoogleUrlTagData.swift
//  GoogleInteractiveMediaAdsTvOS
//
//  Created by Anton Kononenko on 7/25/19.
//  Copyright © 2019 Anton Kononenko. All rights reserved.
//

import Foundation

class GoogleUrlTagData {
    var vmapUrl: String?
    var vastPrerrolUrl: String?
    var vastPostrollUrl: String?
    var vastMidrollsArray: [MidrollTagData] = []
    var tfuaDisablePersonalizedAdvertising: Bool = false

    var isVmapAd: Bool {
        return vmapUrl != nil
    }

    var startedAdExist: Bool {
        return vmapUrl != nil || vastPrerrolUrl != nil
    }

    init(entry: [String: Any]?,
         pluginParams: NSDictionary? = nil) {
        prepareAdvertismentData(entry: entry,
                                pluginParams: pluginParams)
    }

    func tryRetrieveFromPluginParams(pluginParams: NSDictionary?) {
        guard let pluginParams = pluginParams else {
            return
        }

        if let url = pluginParams[PluginsCustomizationKeys.vmapKey] as? String,
            url.isEmpty == false {
            vmapUrl = customizeUrlIfNeeded(url)
        }

        if let url = pluginParams[PluginsCustomizationKeys.prerollUrl] as? String,
            url.isEmpty == false {
            vastPrerrolUrl = customizeUrlIfNeeded(url)
        }

        if let url = pluginParams[PluginsCustomizationKeys.postrollUrl] as? String,
            url.isEmpty == false {
            vastPostrollUrl = customizeUrlIfNeeded(url)
        }

        if let url = pluginParams[PluginsCustomizationKeys.midrollUrl] as? String,
            url.isEmpty == false,
            let offset = pluginParams[PluginsCustomizationKeys.midrollOffset] as? String,
            offset.isEmpty == false,
            let doubleOffset = Double(offset) {
            let midroll = MidrollTagData(url: customizeUrlIfNeeded(url),
                                         timeOffset: TimeInterval(doubleOffset))
            vastMidrollsArray = [midroll]
        }

        /// Tagging users as under the age of consent
        /// https://developers.google.com/interactive-media-ads/docs/sdks/ios/client-side/consent#tagging_users_as_under_the_age_of_consent
        if let tfuaValue = pluginParams[PluginsCustomizationKeys.tfua] {
            var tfuaEnabled = false
            if let tfuaValue = tfuaValue as? String {
                if let tfuaValueBool = Bool(tfuaValue) {
                    tfuaEnabled = tfuaValueBool
                } else if let tfuaValueInt = Int(tfuaValue) {
                    tfuaEnabled = Bool(truncating: tfuaValueInt as NSNumber)
                }
            } else if let tfuaValue = tfuaValue as? Bool {
                tfuaEnabled = tfuaValue
            }

            tfuaDisablePersonalizedAdvertising = tfuaEnabled
        }
    }

    func prepareAdvertismentData(entry: [String: Any]?,
                                 pluginParams: NSDictionary? = nil) {
        guard let extensionDict = entry?[extensionsKey] as? [String: Any],
            let videoAds = extensionDict[videoAdsKey] else {
            tryRetrieveFromPluginParams(pluginParams: pluginParams)
            return
        }

        if let vmapUrl = videoAds as? String {
            self.vmapUrl = vmapUrl
        } else if let videoDataArray = videoAds as? [[String: Any]] {
            var midrollsArray: [MidrollTagData] = []
            videoDataArray.forEach { tagDataDictionary in
                if let adUrl = tagDataDictionary[adUrlKey] as? String {
                    let offset = tagDataDictionary[offsetKey]
                    if let timeOffset = offset as? TimeInterval {
                        midrollsArray.append(MidrollTagData(url: adUrl,
                                                            timeOffset: timeOffset))
                    } else if let offsetString = offset as? String {
                        if offsetString == prerollTypeKey {
                            vastPrerrolUrl = adUrl
                        } else if offsetString == postrollTypeKey {
                            vastPostrollUrl = adUrl
                        }
                    }
                }
            }

            vastMidrollsArray = midrollsArray
        }
    }

    func requestMiddroll(currentVideoTime: TimeInterval) -> String? {
        guard isVmapAd == false else {
            return nil
        }

        var sortedMidrolls = vastMidrollsArray.sorted(by: { $0.timeOffset < $1.timeOffset })
        /// If user seek and jump thought ads we want to present latest add or
        /// If time to show add we are showing the latest one
        var midrollToPresent: MidrollTagData?
        if let index = sortedMidrolls.lastIndex(where: { $0.timeOffset < currentVideoTime }) {
            midrollToPresent = sortedMidrolls[index]
            sortedMidrolls.removeSubrange(0 ... index)
            vastMidrollsArray = sortedMidrolls
        }
        return midrollToPresent?.url
    }

    func prerollUrlString() -> String? {
        return vmapUrl ?? vastPrerrolUrl
    }

    func postrollUrlString() -> String? {
        return isVmapAd ? nil : vastPostrollUrl
    }

    func customizeUrlIfNeeded(_ urlString: String) -> String {
        var retValue = urlString
        if tfuaDisablePersonalizedAdvertising {
            let url = URL(string: urlString)
            let item = URLQueryItem(name: "npa", value: "1")
            if let updatedUrl = url?.appending([item]) {
                retValue = updatedUrl.absoluteString
            }
        }
        return retValue
    }
}

extension URL {
    /// Returns a new URL by adding the query items, or nil if the URL doesn't support it.
    /// URL must conform to RFC 3986.
    func appending(_ queryItems: [URLQueryItem]) -> URL? {
        guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            // URL is not conforming to RFC 3986 (maybe it is only conforming to RFC 1808, RFC 1738, and RFC 2732)
            return nil
        }
        // append the query items to the existing ones
        let queryItemsNames = urlComponents.queryItems?.map { $0.name }
        let filteredItems = queryItems.filter { queryItemsNames?.contains($0.name) == false }
            
        urlComponents.queryItems = (urlComponents.queryItems ?? []) + filteredItems

        // return the url from new url components
        return urlComponents.url
    }
}
