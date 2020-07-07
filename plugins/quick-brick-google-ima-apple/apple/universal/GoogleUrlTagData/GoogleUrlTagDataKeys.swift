//
//  GoogleUrlTagDataKeys.swift
//  GoogleInteractiveMediaAdsTvOS
//
//  Created by Anton Kononenko on 7/25/19.
//  Copyright © 2019 Anton Kononenko. All rights reserved.
//

import Foundation

let extensionsKey = "extensions"
let videoAdsKey = "video_ads"
let adUrlKey = "ad_url"
let offsetKey = "offset"
let prerollTypeKey = "preroll"
let postrollTypeKey = "postroll"

struct PluginsCustomizationKeys {
   static let vmapKey = "tag_vmap_url"
   static let prerollUrl = "tag_preroll_url"
   static let postrollUrl = "tag_postroll_url"
   static let midrollUrl = "tag_midroll_url"
   static let midrollOffset = "midroll_offset"
}

// API example VMPA

//extensions: {
//    video_ads: "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dredirectlinear&correlator="
//}

// API example VAST

//extensions: {
//    video_ads: [
//    {
//    offset: "preroll",
//    ad_url:
//    "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dredirectlinear&correlator=",
//    },
//    {
//    offset: 10,
//    ad_url:
//    "https://pubads.g.doubleclick.net/gampad/ads?sz=1x1&impl=s&gdfp_req=1&env=vp&output=xml_vast2&unviewed_position_start=1&url=televisadeportes.esmas.com&iu=/5644/es.esmas.dep.video.app.iphone/home&ad_rule=1&correlator=[timestamp]",
//    },
//    {
//    offset: 30,
//    ad_url:
//    "https://pubads.g.doubleclick.net/gampad/ads?sz=1x1&impl=s&gdfp_req=1&env=vp&output=xml_vast2&unviewed_position_start=1&url=televisadeportes.esmas.com&iu=/5644/es.esmas.dep.video.app.iphone/home&ad_rule=1&correlator=[timestamp]",
//    },
//    {
//    offset: 50,
//    ad_url:
//    "https://pubads.g.doubleclick.net/gampad/ads?sz=1x1&impl=s&gdfp_req=1&env=vp&output=xml_vast2&unviewed_position_start=1&url=televisadeportes.esmas.com&iu=/5644/es.esmas.dep.video.app.iphone/home&ad_rule=1&correlator=[timestamp]",
//    },
//    {
//    offset: "postroll",
//    ad_url:
//    "https://pubads.g.doubleclick.net/gampad/ads?sz=1x1&impl=s&gdfp_req=1&env=vp&output=xml_vast2&unviewed_position_start=1&url=televisadeportes.esmas.com&iu=/5644/es.esmas.dep.video.app.iphone/home&ad_rule=1&correlator=[timestamp]",
//    },
//    ],
//},
