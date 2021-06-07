import React
import THEOplayerSDK

@objc extension RCTConvert {
    @objc(TypedSource:)
    class func typedSource(_ json: [String: AnyObject]) -> TypedSource? {
        logger?.debugLog(message: "New data source recieved",
                         data: ["source": json])

        if let src = RCTConvert.nsString(json["src"]),
           var type = RCTConvert.nsString(json["type"]) {
            if type == "video/hls" {
                type = "application/vnd.apple.mpegurl"
            }
            if let drm = RCTConvert.nsDictionary(json["drm"]),
               let fairplay = RCTConvert.nsDictionary(drm["fairplay"]),
               let integrationType = RCTConvert.nsString(drm["integration"]) {
                let licenseAcquisitionURL = RCTConvert.nsString(fairplay["licenseAcquisitionURL"])
                let certificateURL = RCTConvert.nsString(fairplay["certificateURL"])
                var baseDrm: THEOplayerSDK.DRMConfiguration?

                // If you want other integration add next case and drm configurator supported by theoplayer sdk 
                switch integrationType {
                case "ezdrm":
                    baseDrm = EzdrmDRMConfiguration(licenseAcquisitionURL: licenseAcquisitionURL!, certificateURL: certificateURL!)
                    break
                case "uplynk":
                    baseDrm = UplynkDRMConfiguration(licenseAcquisitionURL: licenseAcquisitionURL, certificateURL: certificateURL!)
                    break
                case "keyos":
                    if let token = RCTConvert.nsString(drm["customdata"]),
                       let licenseAcquisitionURL = licenseAcquisitionURL,
                       let certificateURL = certificateURL {
                        baseDrm = KeyOSDRMConfiguration(licenseAcquisitionURL: licenseAcquisitionURL,
                                                        certificateURL: certificateURL,
                                                        customdata: token)
                    }
                    break
                default:
                    break
                }

                return TypedSource(src: src, type: type, drm: baseDrm)
            } else {
                return TypedSource(src: src, type: type)
            }

        } else {
            return nil
        }
    }

    @objc(TypedSourceArray:)
    class func typedSourceArray(_ json: [AnyObject]) -> [TypedSource]? {
        let sources = RCTConvertArrayValue(#selector(typedSource), json)
            .compactMap { $0 as? TypedSource }
        return sources.count > 0 ? sources : nil
    }

    @objc(AdDescription:)
    class func adDescription(_ json: [String: AnyObject]) -> GoogleImaAdDescription? {
        if let src = RCTConvert.nsString(json["sources"]) {
            return GoogleImaAdDescription(
                src: src
            )
        } else {
            return nil
        }
    }

    @objc(AdDescriptionArray:)
    class func adDescriptionArray(_ json: [AnyObject]) -> [GoogleImaAdDescription]? {
        let sources = RCTConvertArrayValue(#selector(adDescription), json)
            .compactMap { (item) -> GoogleImaAdDescription? in
                var foo = item as? GoogleImaAdDescription
                foo?.integration = .google_ima
                return foo
            }
        return sources.count > 0 ? sources : nil
    }

    @objc(TextTrack:)
    class func textTrack(_ json: [String: AnyObject]) -> TextTrackDescription? {
        if let src = json["src"].flatMap(RCTConvert.nsString),
           let srclang = json["srclang"].flatMap(RCTConvert.nsString) {
            return TextTrackDescription(
                src: src,
                srclang: srclang,
                isDefault: json["default"].flatMap(RCTConvert.bool),
                kind: json["kind"].flatMap(RCTConvert.nsString).flatMap {
                    TextTrackKind(rawValue: $0)
                },
                label: json["label"].flatMap(RCTConvert.nsString)
            )
        } else {
            return nil
        }
    }

    @objc(TextTrackArray:)
    class func textTrackArray(_ json: [AnyObject]) -> [TextTrackDescription]? {
        let sources = RCTConvertArrayValue(#selector(textTrack), json)
            .compactMap { $0 as? TextTrackDescription }
        return sources.count > 0 ? sources : nil
    }

    @objc(SourceDescription:)
    class func sourceDescription(_ json: [String: AnyObject]) -> SourceDescription? {
        if let sources = (json["sources"] as? [AnyObject]).flatMap(RCTConvert.typedSourceArray) {
            return SourceDescription(
                sources: sources,
                ads: (json["ads"] as? [AnyObject]).flatMap(RCTConvert.adDescriptionArray),
                textTracks: (json["textTracks"] as? [AnyObject]).flatMap(RCTConvert.textTrackArray),
                poster: RCTConvert.nsString(json["poster"]),
                analytics: nil,
                metadata: nil
            )
        } else {
            return nil
        }
    }
}
