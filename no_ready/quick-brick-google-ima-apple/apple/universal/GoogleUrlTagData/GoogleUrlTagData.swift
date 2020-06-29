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
            vmapUrl = url
        }

        if let url = pluginParams[PluginsCustomizationKeys.prerollUrl] as? String,
            url.isEmpty == false {
            vastPrerrolUrl = url
        }

        if let url = pluginParams[PluginsCustomizationKeys.postrollUrl] as? String,
            url.isEmpty == false {
            vastPostrollUrl = url
        }

        if let url = pluginParams[PluginsCustomizationKeys.midrollUrl] as? String,
            url.isEmpty == false,
            let offset = pluginParams[PluginsCustomizationKeys.midrollOffset] as? String,
            offset.isEmpty == false,
            let doubleOffset = Double(offset) {
            let midroll = MidrollTagData(url: url,
                                         timeOffset: TimeInterval(doubleOffset))
            vastMidrollsArray = [midroll]
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
}
